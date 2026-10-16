# SofaRobotics.CI

Scripts and GitHub actions to package SOFA for Compliance Robotics.

Specificities:
- Bundled Python
- Compliance Robotics GUI 

## Action Usage 

⚠️ Avoid using this action if you just want the default SOFA Robotics binaries you can download from the release page of [SofaRobotics.CI](https://github.com/SofaComplianceRobotics/SofaRobotics.CI/releases). Also avoid using it in a scheduled job.

- This action builds SOFA from source to allow for custom plugin and dependencies.
- Build SOFA-Robotics binaries for Linux, Windows and MacOS. 
- By default, it builds the latest SOFA from main branch, the latest SoftRobot, SoftRobot.Inverse, STLIB, SofaPython3, BeamAdapter, Cosserat and Compliance Robotics SofaGLFW/robotics plugins
- It then uploads the binaries as artifacts to the workflow run.
- To retrieve the artifacts, go to the workflow run and download them from the "Artifacts" section. Or from within your action, use the "actions/download-artifact" action.

