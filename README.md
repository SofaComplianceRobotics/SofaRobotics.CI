# SofaRobotics.CI

Scripts and GitHub actions to package SOFA for Compliance Robotics.

Specificities:
- Bundled Python
- Compliance Robotics GUI 

## Action Usage 

> [!WARNING]
> Avoid using this action if you just want the default SOFA Robotics binaries you can download from the release page of [SofaRobotics.CI/release](https://github.com/SofaComplianceRobotics/SofaRobotics.CI/releases).
> Also avoid using it in a scheduled job.

- This action builds SOFA from source to allow for custom plugin and dependencies.
- Build SOFA-Robotics binaries for Linux, Windows and MacOS. 
- By default, it builds the latest:
  - *SOFA* from master branch,
  - *SoftRobots*,
  - *SoftRobots.Inverse*,
  - *STLIB*,
  - *SofaPython3*,
  - *BeamAdapter*,
  - *Cosserat*, and
  - Compliance Robotics *SofaGLFW/robotics* plugins
- It then uploads the binaries as artifacts to the workflow run.
- To retrieve the artifacts, go to the workflow run and download them from the "Artifacts" section. Or from within your action, use the `actions/download-artifact` action.

### Inputs

```yaml
- uses: SofaComplianceRobotics/SofaRobotics.CI@main
  with:
    # [Required] Operating system to build for (ubuntu-22.04, windows-2025, macos-14)
    os:

    # [Optional] SOFA branch or commit to build
    # Default is 'master'
    sofa_target:

    # [Optional] Plugins repository to add (custom link, branch, commit). Specified as JSON with repo url as key and branch as value. Example: {"https://github.com/SofaComplianceRobotics/SofaPython3.git": "master", "my/repo/path.git": "my-branch"}
    # Default is {"https://github.com/sofa-framework/BeamAdapter.git": "master",
    #    "https://github.com/SofaComplianceRobotics/SofaPython3.git": "pr_bundlepython",
    #    "https://github.com/SofaDefrost/SoftRobots.git": "master",
    #    "https://github.com/SofaDefrost/SoftRobots.Inverse.git": "main",
    #    "https://github.com/SofaDefrost/Cosserat.git": "master",
    #    "https://github.com/SofaDefrost/STLIB.git": "master",
    #    "https://github.com/SofaComplianceRobotics/SofaGLFW.git": "robotics"
    #    }
    plugins_repos:

    # [Optional] Python version to use (ex: 3.10.4)
    # Default is '3.14.7'
    python_version:

    # [Optional] URL or path to requirements.txt file for Python dependencies
    # Default is empty
    requirements_file:

    # [Optional] The SOFA version in the binaries filename. If empty, it will take the value of the sofa_target input.
    # Default is empty
    sofa_version:
```
