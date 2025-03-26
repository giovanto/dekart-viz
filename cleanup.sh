#!/bin/bash

# Clean up deprecated files and move them to the deprecated folder
echo "Cleaning up deprecated files..."

# Create list of essential scripts
ESSENTIAL_SCRIPTS=(
    "start-dekart-viz.sh"
    "import-data.sh"
    "create-views.sh"
    "create-base-views.sh"
    "create-styled-views.sh"
    "import-styled-base-layers.sh"
    "cleanup-database.sh"
    "cleanup.sh"
)

# Check and move non-essential scripts to deprecated folder
for file in *.sh; do
    if [[ ! " ${ESSENTIAL_SCRIPTS[@]} " =~ " ${file} " ]]; then
        echo "Moving $file to deprecated folder..."
        mv "$file" "deprecated/"
    fi
done

echo "Cleanup completed successfully!"
echo ""
echo "Essential scripts preserved:"
for script in "${ESSENTIAL_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "- $script"
    fi
done
echo ""
echo "To start the platform, run:"
echo "./start-dekart-viz.sh"
echo ""
echo "To import data, run:"
echo "./import-data.sh"
echo ""
echo "To create visualization views, run:"
echo "./create-views.sh"