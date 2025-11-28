# Mapbox iOS Setup Instructions

To download the Mapbox SDK for iOS, you need to configure your secret token in a `.netrc` file in your home directory.

1.  **Get your secret token**: Go to your Mapbox account and create a secret token with `Downloads:Read` scope.
2.  **Create or edit `.netrc`**:
    Open your terminal and run:
    ```bash
    nano ~/.netrc
    ```
3.  **Add the following content**:
    Replace `YOUR_SECRET_MAPBOX_ACCESS_TOKEN` with your actual secret token.
    ```
    machine api.mapbox.com
    login mapbox
    password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
    ```
4.  **Save and exit**: Press `Ctrl+X`, then `Y`, then `Enter`.

This file is required for `pod install` to work correctly when fetching the Mapbox SDK.
