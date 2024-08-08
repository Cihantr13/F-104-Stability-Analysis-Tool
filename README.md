# Aircraft Stability Analysis - F-104 Aircraft

This MATLAB project performs stability analysis for the F-104 aircraft at different altitudes (sea level and 55,000 ft) based on input data from a text file. The analysis includes both static and dynamic stability calculations, and it provides visualizations of various stability modes such as short period, long period, roll, spiral, and Dutch roll modes.

## Project Structure

- `stability1.m`: Main function that performs the stability analysis.
- `read_data.m`: Helper function that reads input data from a text file.
- `data.txt`: Input data file containing aircraft properties, freestream conditions, and stability derivatives.

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/aircraft-stability-analysis.git
    ```

2. Ensure that you have MATLAB installed on your machine.

## Usage

1. Place the `data.txt` file in the same directory as the `stability1.m` and `read_data.m` files.

2. Open MATLAB and navigate to the project directory.

3. Run the `stability1.m` function to perform the stability analysis. You need to specify the altitude index (`1` for sea level, `2` for 55,000 ft).

    Example:
    ```matlab
    [lam_sp, lam_lp, lam_s, lam_r, lam_dr] = stability1(1);
    ```

4. The function will read the input data from `data.txt`, perform the calculations, and display the results in the MATLAB command window and plots.

## Input Data Format

The input data is stored in a text file `data.txt`. The file contains the following sections:

- **Wing and Aircraft Properties**:
    - `S`: Wing area (ft²)
    - `b`: Wingspan (ft)
    - `c`: Mean aerodynamic chord (ft)
    - `Xcg`: Center of gravity location
    - `W`: Weight of the aircraft (lb)
    - `Ixx`, `Iyy`, `Izz`, `Ixz`: Moments of inertia (slug·ft²)

- **Freestream Conditions**:
    - `M1`: Mach number at sea level
    - `M2`: Mach number at 55,000 ft
    - `V`: Freestream velocity (ft/s)
    - `Q`: Dynamic pressure 

- **Stability Derivatives**:
    - The `static` matrix contains the stability derivatives for different altitudes:
      - `static(1,:)`: Stability derivatives at sea level
      - `static(2,:)`: Stability derivatives at 55,000 ft
