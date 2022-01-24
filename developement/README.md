# Development with Invenio

This guidance is made for VS Code IDE and can be used as a  pattern for other development environments.

# Invenio instance

First of all, an invenio instance must be installed. This can be done either manually (the link below shows how to setup the invenio instance)

https://inveniordm.docs.cern.ch/install/

Or use an already created invenio instance.
In the root project directory, add the directory ```.vscode/``` and 
create a launch configuration as described in the following section. 

<br/>

# Run and debug the invenio instance

Example configuration debugging your local invenio instance


---

File launch.json: 

```json
{
    "name": "Repository Debug",
    "type": "python",

    "request": "launch",
    "program": "{{virtualenv}}/bin/invenio",
    "env": {
        "FLASK_ENV": "development",
        "FLASK_DEBUG": "1"
    },
    "args": [
        "run",
        "--no-reload",
        "--cert",
        "{{repositoryDir}}/docker/nginx/test.crt",
        "--key",
        "{{repositoryDir}}/docker/nginx/test.key",
    ],
    "preLaunchTask": "",
    "jinja": true,
}
```

Set the environment variable ```FLASK_ENV``` to development. This configuration starts the flask server, initialize the debug mode, and connects the auto reloader when files are changed in the project. Both options can be disabled by adding the argument "--no-debugger" and "--no-reloader".

More information: https://flask.palletsprojects.com/en/1.1.x/cli/

# Develop an invenio module

Develop a new invenio module or work on an existing module with VS Code; many settings and launch configurations can be set within the project folder, and you can be reused for other modules.

In the project directory must be created a folder with the name ```.vscode``` within three files can be placed to configure VS Code:
```launch.json```, ```settings.json``` and ```tasks.json```.

## Project sturcture

  ```
  my-invenio-project
    .vscode/                     <-- configuration files for vscode
      launch.json
      tasks.json
      settings.json
    repo/                        <-- invenio repository directory
      app_data/
      assets/                    
      docker/
      static/
      templates/
    venv/                        <-- python virtual enviroment
  ```

The ```launch.json``` configuration file is used to configure the debugger for running the test-set of the project or configure the debugger for your invenio instance, as shown in the previous section. For more information, read this articles [Configuration](https://go.microsoft.com/fwlink/?linkid=830387) and [Debugging](https://code.visualstudio.com/docs/python/debugging).


The ```settings.json``` file is the easy way to configure VS Code for your purpose.

In this file, the visual studio code can be customized and automated for each type of file. Setup the action if a python file will be saved and organize with isort the imports in the python file and format the code with your specified code styler.

```json
"[python]": {
    
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    },
    "editor.formatOnSave": true,
  },
```

or specify a specific python interpreter to run your program.
```json
"python.pythonPath": "venv/bin/python",
```

In the last file, ```tasks.json``` tasks can be configured to run scripts and start processes so that many of these existing tools can be used from within VS Code. The specified tasks can be executed before the launch by adding the following line to the launch configuration ```json "preLaunchTask": "testset", ```.
Further information can be found [here](https://go.microsoft.com/fwlink/?LinkId=733558).

An example configuration can be found in the folder: [.vscode/](.vscode/)

# Debug module Test-set

The Visual Studio Code supports the python unittest framework. The VS Code extension 
```hbenl.vscode-test-explorer``` is a useful extension to display and run unittest in the module. VS Code can be configured to run unittest by adding the line ```python.testing.pytestEnabled``` in the ```settings.json``` file.

## Configuration

Writing unit-test during development is a crucial thing. Vscode can sometimes be tricky to configure; an important step is to set up the environment. In order to use the debugger ``launch.json`` file must have a configuration section as follows: 

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Debug Unit Tests",
            "type": "python",
            "request": "launch",
            "purpose": ["debug-test"],
            "console": "integratedTerminal",
            "justMyCode": false,
        }
    ]
}
```
Most of the time, you need to debug through the whole source code with the property ``"justMyCode": false`` debugpy works also in other libraries.

## Troubleshoot

+ VS Code has problems auto-discover the test-set in the module:
  
  Disable coverage check for pytest by adding the argument "--no-cov" to the "python.testing.pytestArgs".
***

## Usefull extentions for VS Code


```
code --install-extension Cameron.vscode-pytest
code --install-extension christian-kohler.npm-intellisense
code --install-extension christian-kohler.path-intellisense
code --install-extension cstrap.flask-snippets
code --install-extension dbaeumer.vscode-eslint
code --install-extension donjayamanne.githistory
code --install-extension donjayamanne.python-extension-pack
code --install-extension eg2.vscode-npm-script
code --install-extension formulahendry.code-runner
code --install-extension formulahendry.docker-explorer
code --install-extension hbenl.vscode-test-explorer
code --install-extension jasonnutter.search-node-modules
code --install-extension jawandarajbir.react-vscode-extension-pack
code --install-extension littlefoxteam.vscode-python-test-adapter
code --install-extension mhutchie.git-graph
code --install-extension mikeshaker.python-essentials
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension msjsdiag.vscode-react-native
code --install-extension tht13.python
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension waderyan.gitblame
```
