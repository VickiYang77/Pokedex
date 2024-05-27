# Pokedex iOS App

## Overview

This iOS application is a Pokedex app that utilizes PokeAPI v2 to display information about Pokemon. The app allows users to browse a list of Pokemon, view detailed information about each one, mark their favorites, and filter the list to show only favorites. The app is designed with a user-friendly interface and incorporates several key features:

- Display a list of Pokemon from ID 0001 to the latest (ID 1017 or larger), sorted by their National Pokedex ID number.
- Show basic information for each Pokemon including ID, name, types, and thumbnail image.
- Navigate to a detailed page for each Pokemon, showing comprehensive information such as evolution chain, Pokedex description, and more.
- Mark/unmark Pokemon as favorites, with this data saved locally.
- Filter the list to display only favorite Pokemon.
- Automatically load more Pokemon data as the user scrolls.

## Running the Application

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.0 or later

### Setup Steps

1. **Clone the Repository**
    
    ```bash
    git clone https://github.com/VickiYang77/Pokedex.git
    cd Pokedex
    ```
    
2. **Install Dependencies**
    
    ```bash
    pod install
    ```
    
    Then open the generated workspace:
    
    ```bash
    open Pokedex.xcworkspace
    ```
    
3. **Build and Run**
Select the target device or simulator in Xcode and click the "Run" button.

## Design Patterns Used

### MVVM (Model-View-ViewModel)

The application is structured using the MVVM pattern to separate concerns and enhance testability:

- **Model:** Represents the data and business logic. Includes Pokemon data models and API services.
- **View:** Represents the UI components such as view controllers and custom views.
- **ViewModel:** Acts as an intermediary between the View and the Model, handling presentation logic and data binding.

### Singleton

The APIManager and AppManager are implemented as singletons to provide a single point of access for managing API requests and shared application state, respectively.

### Dependency Injection

Dependencies are injected into view models and view controllers to decouple components and improve modularity.


## Features

### Pokemon List

1. **Display Basic Info:**
    - **Pokemon ID**: Displayed in the format `#0001`.
    - **Name**: The name of the Pokemon.
    - **Types**: Display the types of the Pokemon.
    - **Thumbnail Image**: Display a small image of the Pokemon.
2. **Navigation to Detail Page:**
    - Tapping on a Pokemon entry navigates to its detailed page.
3. **Automatic Loading:**
    - More Pokemon data is loaded automatically as the user scrolls to the end of the list.
4. **Favorite Marking:**
    - Users can mark or unmark any Pokemon as a favorite, with the data saved locally using User Defaults.
5. **Favorite Filter:**
    - Users can filter the list to display only favorite Pokemon.
6. **Switch Between List and Grid Views:**
    - Users can switch between list and grid views to display the Pokemon list in their preferred layout.

### Pokemon Detail

1. **Comprehensive Information:**
    - **Pokemon ID**: Displayed in the format `#0001`.
    - **Name**: The name of the Pokemon.
    - **Types**: Display the types of the Pokemon.
    - **Images**: Display the Pokemon's images (front default).
    - **Evolution Chain**: Display the evolution chain if available.
        - Tapping on an evolution chain Pokemon navigates to its detail page.
    - **Pokedex Description**: Display a description text from the Pokedex.
        - The description is chosen based on locale or default to English.
2. **Favorite Marking:**
    - Users can mark or unmark the Pokemon as a favorite, with the data saved locally using User Defaults.
3. **Convenient Navigation:**
    - A button is provided for users to quickly return to the home page from the detail view.
