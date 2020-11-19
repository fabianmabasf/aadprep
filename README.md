# aadprep

Some preparation samples for [Azure Adventure Day](https://aka.ms/azure-adventure-day),

It is always a good idea to carefully look at the all the code!

And to follow the instructions provided.

## Deploy this

1. Optional (but might be a good idea for collaborating with others): [Import](https://docs.github.com/en/free-pro-team@latest/github/importing-your-projects-to-github/importing-a-repository-with-github-importer) or [fork](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) this repository into your own GitHub account.

1. Log on to cloud shell with the credentials provided.

1. Clone this repository (use the URL of your own account in case you forked or imported):
    ```sh
    git clone https://github.com/cadullms/aadprep
    ```

1. Deploy our infrastructure:
    ```sh
    cd aadprep
    cd tf
    terraform init
    terraform apply --var "name_prefix=<some_name>" 
    ```
    Terraform will display the changes it will make and asks for your confirmation. Confirm with `yes` and the infrastructure will be deployed.

1. Get Kubernetes config and deploy our solution:
    ```sh
    cd ..
    cd k8s
    az aks get-credentials --name <some-name>aks --resource-group <some-name>rg
    kubectl apply -f theapp.yaml
    ```
1. Check our solution:
    ```sh
    kubectl get svc
    ```
    From the output of this, copy the external IP for our service and enter it in a web browser. That should then show you something like this:

    ![Our app's start page](./media/appstartpage.png)

## Change this

1. Configure a setting through an environment variable.

   First, assuming we are still in the `k8s` directory, open an editor (here, we are using `code theapp.yaml` to open the file directly in the cloud shell version of Visual Studio Code. You might as well use vi, nano or another editor of choice):

   ```sh
   code theapp.yaml
   ```

   In the file, navigate to the container configuration:

   ```yaml
    spec:
      containers:
      - image: docker.io/cadull/theapp:latest
        imagePullPolicy: Always
        name: theapp
        env:
        - name: STAGE
          value: "K8S"
        resources:
          limits:
            memory: 200Mi
            cpu: "0.4" 
          requests:
            memory: 20Mi
            cpu: "0.04" 
   ```
   This configuration sets the environment variable `STAGE`to the value "K8S" (which you should have seen as the stage being displayed in the browser).

   In the editor, change "K8S" to "Production" (or whatever you would like to see in the web page) and save the file (`Ctrl+S` works in VS Code).

   Then, apply the configuration again:

   ```sh
   kubectl apply -f theapp.yaml
   ```

   Because the configuration was changed, Kubernetes will now start exchanging the pods of our application one by one with the new config. You can watch this happening:

   ```sh
   kubectl get pod --watch
   ```
   (and leave the watch using `Ctrl+C`)

   Once all pods are new, you can browse to our website again (the service IP you copied in one of the previous steps) and you should see the new label coming up.

1. So far, the workload uses a static precompiled container image that is available from Docker Hub (`docker.io/cadull/theapp:latest`).

   If we want to change more than just an environment variable, we need to build a new container image. For example, we might want to change the behaviour of an algorithm in our code, or simply change the text that presents our stage label.

   A very handy way of doing this in Azure is to use the Azure Container Registry (ACR). That way, we do not need to aquire a Docker host machine (the cloud shell only contains the Docker client, it is not connected to a Docker daemon by default).

   First, navigate to the directory containing our app's code and open an editor (here, we are using `code .` to open the whole directory in the cloud shell version of Visual Studio Code. You might as well use vi, nano or another editor of choice):

   ```sh
   cd ..
   cd theapp
   code .
   ```

   In the editor, navigate to `theapp\Controllers\HomeController.cs`. In the file, locate the `Index` method:

   ```cs
        public IActionResult Index()
        {
            var stage = _configuration.GetValue<string>("STAGE", "N/A");
            ViewData["Message"] = $"We are in stage {stage}.";
            return View();
        }
   ```

   Change `"We are in stage {stage}"` to `"Stage: {stage}"` to make the message more neutral (or do whatever fancy change you would like to do to this code).

   Build the image in ACR:

   ```sh
   az acr build -t aadprep/theapp:latest -r <some_name>reg .
   ```

   Where `<some_name>` needs to be replaced with the name you chose in the beginning, when deploying the infrastructure through Terraform (including an ACR that we will be using now).

   This builds the new container image directly in the ACR, and we can use it right away.