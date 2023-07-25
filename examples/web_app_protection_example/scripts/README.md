# Startup scripts folder

In this folder we have the startup scripts used to configure the instances that are the backends of the solution.

The content of the scripts listed in this folder is a literal representation of the startup-script of a Compute Instance. Therefore, if you want to reproduce the settings defined for the startup script of a backend that is already running in the GCP environment, just copy the content of the startup script of the desired instance and replace the content of the startup-script.sh file located on this folder.

This action, if performed before deploying the environment, will cause the managed instance groups templates to be created already using the desired startup script settings.

If the action is performed after the environment has already gone through the first deployment process, this action will recreate the Managed Instance Group template file and will trigger the Managed Instance Group to replace the current instances with new instances using the new template.

### * Note that in the example we used, we automated not only the process of deploying the instance with its basic configurations, but also added the configurations related to our example application.

As we are using Managed Instance Groups, we recommend that a similar automation process be performed for the deployment of your application using the startup script.

