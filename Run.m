clc; clear all; close all;

% Prompt user to select the case
i = input('Select Case\n 1: Sea level\n 2: At 55000 ft\n');

%% Read data from text file
filename = 'data.txt';
data = read_data(filename);

% Extract the variables from the data structure
S = data.S; 
b = data.b; 
c = data.c; 
Xcg = data.Xcg; 
W = data.W; 
Ixx = data.Ixx; 
Iyy = data.Iyy; 
Izz = data.Izz; 
Ixz = data.Ixz; 
M1 = data.M1; 
M2 = data.M2; 
V = data.V; 
Q = data.Q;
static = data.static;

% Mass and gravity
m = W / 32.17405; % mass (slug)
g = 32.17405; % gravity acceleration (ft/s^2)

if i == 1 || i == 2
    %% Static Stability Calculation
    % Longitudinal static stability
    if static(i, 7) <= 0
        fprintf('CLa = %.4f, CLa < 0, longitudinally statically stable!\n', static(i, 7));
    else
        fprintf("CLa = %.4f, CLa > 0, not longitudinally statically stable!\n", static(i, 7));
    end

    % Directional (Weathercock) stability
    if static(i, 14) >= 0
        fprintf("CnB = %.4f, CnB > 0, Statistically stable as directional!\n", static(i, 14));
    else
        fprintf("CnB = %.4f, CnB < 0, not Statistically stable as directional!\n", static(i, 14));
    end

    % Static rolling stability
    if static(i, 10) <= 0
        fprintf("ClB = %.4f, ClB < 0, Statistically stable as rolling!\n", static(i, 10));
    else
        fprintf("ClB = %.4f, ClB > 0, not Statistically stable as rolling!\n", static(i, 10));
    end

    %% Dynamic Stability
    Xu = -(static(i, 4) + 2 * static(i, 2)) * ((Q * S) / (m * V)); % s^-1
    Zu = -(static(i, 3) + 2 * static(i, 1)) * ((Q * S) / (m * V)); % s^-1
    Za = -(static(i, 5) + static(i, 2)) * (Q * S / m); % m/s^2
    Ma = static(i, 7) * (Q * S * c) / Iyy; % s^-2
    Mq = static(i, 9) * (c / (2 * V)) * (Q * S * c) / Iyy; % s^-1
    Mdota = static(i, 8) * (c / (2 * V)) * ((Q * S * c) / Iyy); % m^-1

    %% Short Period
    Wn_sp = sqrt(Mq * Za / V - Ma);
    Ksi_sp = -(Mq + Mdota + Za / V) / (2 * Wn_sp);
    n_sp = -Ksi_sp * Wn_sp;
    ksi_sp = [-sqrt(1 - Ksi_sp^2) * Wn_sp, sqrt(1 - Ksi_sp^2) * Wn_sp];

    lam_sp = [n_sp, n_sp; ksi_sp];

    % Plotting
    subplot(2, 2, 1);
    hold on
    plot(n_sp, ksi_sp, '-b*', 'LineWidth', 1.1)
    title('Short Period')
    grid

    %% Long Period
    Wn_lp = sqrt(-Zu * g / V);
    Ksi_lp = -Xu / (2 * Wn_lp);
    n_lp = [-Ksi_lp * Wn_lp];
    wd_lp = [-sqrt(1 - Ksi_lp^2) * Wn_lp, sqrt(1 - Ksi_lp^2) * Wn_lp];

    lam_lp = [n_lp, wd_lp(1, 1); n_lp, wd_lp(1, 2)];

    % Plotting
    subplot(2, 2, 2);
    hold on
    plot(n_lp, wd_lp, '-k*', 'LineWidth', 1.1)
    title('Long Period')
    grid

    %% Lateral
    LB = static(i, 10) * (Q * S * b / Ixx);
    Lp = static(i, 17) * (Q * S * b / (2 * Ixx * V));
    Lr = static(i, 11) * (Q * S * (b^2) / (2 * Ixx * V));
    NB = static(i, 14) * (Q * S * b / Izz);
    Np = static(i, 16) * (Q * S * (b^2) / (2 * Ixx * V));
    Nr = static(i, 15) * (Q * S * (b^2) / (2 * Ixx * V));
    YB = static(i, 12) * (Q * S / m);
    Yr = static(i, 13) * (Q * S / (2 * m * V));

    %% Spiral Mode
    lam_s = (Lr * LB - LB * Nr) / (-LB + (V / g) * (LB * Np - Lp * NB));

    %% Roll Mode
    lam_r = Lp;

    %% Dutch Roll Mode
    W_n_dr = ((1 / V) * (YB * Nr - NB * Yr) + NB)^2;
    ksi_dr = -(0 / (2 * W_n_dr)) * (YB / V + Nr);
    n_dr = -ksi_dr * W_n_dr;
    ksi_dr = [-sqrt(1 - ksi_dr^2) * W_n_dr, sqrt(1 - ksi_dr^2) * W_n_dr];
    lam_dr = [n_dr, ksi_dr(1, 1); n_dr, ksi_dr(1, 2)];

    % Plotting
    subplot(2, 2, 3);
    plot(n_dr, ksi_dr, '-r*', 'LineWidth', 1.1)
    title('Dutch Roll Mode')
    grid
else
    error('i takes the values 1 and 2')
end

fprintf('lam = [n +/- wd]\n')

function data = read_data(filename)
    % Initialize a structure to hold the data
    data = struct();
    static_data = [];  % To hold the static stability data

    % Open the file for reading
    fid = fopen(filename, 'r');

    % Read lines until end of file
    while ~feof(fid)
        % Get the current line
        line = fgetl(fid);

        % Ignore empty lines and comments
        if isempty(line) || startsWith(line, '%')
            continue;
        end

        % Parse the line to extract the variable name and value
        tokens = regexp(line, '(\w+)\s*=\s*([\d.\-]+)', 'tokens');

        if ~isempty(tokens)
            % Extract the variable name and value
            var_name = tokens{1}{1};
            var_value = str2double(tokens{1}{2});

            % Assign the value to the corresponding field in the data structure
            data.(var_name) = var_value;
        else
            % Try to read the static stability data
            static_data_line = sscanf(line, '%f');
            if ~isempty(static_data_line)
                static_data = [static_data; static_data_line'];
            end
        end
    end

    % Close the file
    fclose(fid);

    % Add the static data to the structure
    if ~isempty(static_data)
        data.static = static_data;
    end
end
