![qroclbp9qe8m3d9hahj](https://github.com/user-attachments/assets/0fa0d3f3-88ec-4a1f-ab0c-2f1e7c874d61)

# OOrb: tracking and triangulating firefly flashes in steroscopic 360-degree video recordings

**oorb** is a Matlab project to analyse in-field recordings of firefly display. 

## Features
- **Orbit class**: defines Orbit class to store and access intermediate data (new)
- **CNN based flash detection**: reliable flash identification based on trained firefly-net network
- **Calibration-free triangulation**: estimates camera delay and pose from the data, no in-field calibration needed
- **Trajectory generation**: concatenates flashes into streaks and trajectories

## To-Do
- optimize tracking for speed (ongoing)
- Python version (soon)

## Installation
Clone the repository:
```bash
git clone https://github.com/your-username/oorb.git
cd oorb
