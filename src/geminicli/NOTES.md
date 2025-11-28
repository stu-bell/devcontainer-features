
Also, how to generate the feature README ?

try devcontainer help features 

So it seems to work with the typescript image, but not the base:ubuntu (despite this being in the test?!)

{
    "image": "mcr.microsoft.com/devcontainers/typescript-node",
    "features": {
        "../geminicli": {}
    }
}

this works for ubuntu, if node is specified in the installsAfter property

        "ghcr.io/devcontainers/features/node": {
          "version": "lts" 
      }
