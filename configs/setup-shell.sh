
# TermiDesk Shell Customization

# Initialize Starship if installed
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Run Neofetch on start if installed
if command -v neofetch &> /dev/null; then
    neofetch
fi
