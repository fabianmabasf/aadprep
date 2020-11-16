# aadprep

Some preparation samples for [Azure Adventure Day](https://aka.ms/azure-adventure-day),

It is always a good idea to carefully look at the all the code!

And to follow the instructions provided.

## Deploy this

1. Optional (but might be a good idea): [Import](https://docs.github.com/en/free-pro-team@latest/github/importing-your-projects-to-github/importing-a-repository-with-github-importer) or [fork](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) this repository into your own GitHub account.

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
    terraform apply --var "name_prefix=<some_name>" --auto-approve
    ```

1. Get Kubernetes config and deploy our solution:
    ```sh
    cd ..
    cd k8s
    az aks get-credentials --name <some-name>aks --resource-group <some-name>rg
    kubectl apply -f theapp.yaml
    ```

