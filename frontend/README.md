# UTMarketplace Mobile Frontend Development Guide

## Adding New Views

To add a new view to the mobile frontend, follow these steps:

### 1. Create a New Folder

Create a new folder under `lib` for the new view you want to make.

### 2. Folder Structure

The view folder should typically have the following subfolders:

- `components`
- `models`
- `viewmodels`
- `repository`
- `view`

### 3. Responsibilities

- **Repository**: Responsible for fetching data from the backend.
- **Models**: Responsible for parsing repository data.
- **ViewModel**: Responsible for fetching model data and is called in the view.
- **View**: Reads and builds from the fetched data in the ViewModel and renders it accordingly.

### 4. Development Steps

1. **Repository**: Start by creating the repository and connect it to the necessary backend endpoint it should retrieve data from.
2. **Model**: Create the model that reads the data (e.g., JSON) from the repository fetch.
3. **ViewModel**: Create the ViewModel. Ensure that the ViewModel extends the `shared/view_models/loading.viewmodel.dart` class.
4. **View**: Create the view using the ViewModel data.

### 5. Using Temporary Data

If the backend is not ready, you can use temporary data for the repository. Follow these steps:

1. Create a new JSON file with fake data in the `assets/data` folder.
2. In the repository, load the JSON file using the `rootBundle.loadString` method.
3. Parse the JSON data and return it to the model through the model's fetchData function.

### 6. Decoupling Code

To decouple the code, you can create a `components` directory to split the code amount of the view file and modularize it. Create a subfolder under `components` for each new component.

### 7. Connecting to Locator

After creating the repository, connect it to the locator in `locator.dart`. Then, in `main.dart`, add the ViewModel and the repository to the `MultiProvider`.

### 8. Adding a Route

Add a route for the new view in `shared/routes/routes.dart`.

### 9. Using Loading Component

Use the loading component under `shared/components/loading.component.dart` for rendering waiting data from the model in views.

By following these steps, you can efficiently add new views to the mobile frontend of UTMarketplace.
