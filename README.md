 # V1
This action automates the process of creating version tags for different branches in your project. It ensures that the new tag is generated based on the latest tag in the branch and the label of the most recent PR that has been merged. In other words, it keeps track of the project's versioning and labels, making it easier to manage and understand the project's history and changes.



```yaml
steps:
  - uses: gustavo1020/-release-version-@v4
    with:
      list-version-fragment: ${{secret.LIST-VERSIONS-FRAGMENTS}} // "major feature bug hotfix fix"
```