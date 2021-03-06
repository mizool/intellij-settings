# mizool IntelliJ settings
## What is this?
The purpose of this repository is to keep the mizool codestyle in sync across several developer machines and several projects.
Mizool opted for this approach as including the code style in every project repository does not scale well.
# Usage
This repository is intended to be checked out in place with your IntelliJ settings.
For windows machines, those are located under `%APPDATA%\JetBrains\IntelliJIdea<version>`, where `<version>` changes with IntelliJ updated.

If you haven't used the mizool code style before, you can simply perform a checkout of this repository into your current settings folder.
If you already have a `codestyles/mizool.xml`, you might want to move it aside before performing the checkout and then move it back afterwards and check for changes.
In case there are any changes that should flow back into this repository, please talk to one of the contributors.

To keep your local settings up do date, you can place a shortcut to `sync.cmd` in your `shell:startup` folder.
Note that the `<version>` changes with every major update of IntelliJ.
You will have to modify the shortcut manually to point to the correct folder.
The script will automatically pull the latest version from this repository, but will warn you if you have uncommitted changes so you can review them before losing anything.