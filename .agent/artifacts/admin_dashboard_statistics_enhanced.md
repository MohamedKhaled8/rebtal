# Admin Dashboard Statistics Enhancement

This document outlines the enhancements made to the Admin Dashboard's statistics section to provide real-time data visualization and detailed, high-contrast metrics.

## Key Features

1.  **Multi-Line Chart (Unified FlowChart):**
    *   **Consolidated View:** Displays Users, Chalets, Bookings, and Revenue trends on a single interactive chart.
    *   **Interactive Toggles:** Users can toggle the visibility of each metric (Users, Chalets, Bookings, Revenue) individually via a custom legend.
    *   **Smart Scaling:** Revenue figures are automatically scaled (e.g., divided by 1000) to visually fit alongside count-based metrics, with actual values shown in tooltips.
    *   **Robust Data Handling:** Implements fallback logic to handle missing `createdAt` dates in legacy data, ensuring no metric line "disappears" or defaults to zero unexpectedly.

2.  **Premium Visualizations:**
    *   **Style:** Smooth curves with gradient fills (fading from color to transparent).
    *   **Interactivity:** Sorted tooltips showing all active metrics at the touched point.
    *   **Clarity:** Thicker lines (5px) and non-overshooting curves for a cleaner look.
    *   **Donut Charts:**
        *   **Chalet Status:** Active vs. Pending (Emerald vs. Red).
        *   **Booking Status:** Completed, Accepted, Pending, Cancelled.
        *   **Center Text:** Shows total count and label in the donut hole.

3.  **Real-time Data Updates:**
    *   Listens to live streams from Firestore collections (`Users`, `Owners`, `Admin`, `users`, `chalets`, `bookings`).
    *   Updates are reflected instantly.

4.  **UI/UX Design:**
    *   **Color Coding:** Consistent color scheme (Users=Blue, Bookings=Amber, Revenue=Pink, Chalets=Emerald).
    *   **Responsive Layout:** Adapts to screen sizes.
    *   **Glassmorphism/Shadows:** High-quality shadows and borders.

## Technical Implementation

*   **State Management:** `StreamSubscription` in `StatefulWidget`.
*   **Data Structures:**
    *   `_allUsersData`: Map for unified user tracking.
    *   `_chartVisibility`: Map<String, bool> to manage chart series visibility.
*   **Dependencies:** `fl_chart`, `cloud_firestore`.
