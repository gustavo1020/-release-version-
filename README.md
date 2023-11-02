 # V1
This action automates the process of creating version tags for different branches in your project. It ensures that the new tag is generated based on the latest tag in the branch and the label of the most recent PR that has been merged. In other words, it keeps track of the project's versioning and labels, making it easier to manage and understand the project's history and changes.

Add the top 5 labels to your repository with their respective names.
![image](https://github.com/gustavo1020/-release-version-/blob/dsd/img/Screenshot%202023-11-02%20172203.png)

Using the labels from your repository, set them as secrets in GitHub in the following order: ej the secret = "major feature bug hotfix fix"
- "major" (major change)
- "feature" (new feature)
- "bug" (software error, regardless of whether it's in production or pre-production)
- "hotfix" (error in a feature requested in production)
- "fix" (error in a feature requested in pre-production)

Prioritize having only 1 label out of the 5 declared; if it contains others that are not in the previous list, that's not a problem."


```yaml
steps:
  - uses: gustavo1020/-release-version-@v4
    with:
      list-version-fragment: ${{secret.LIST-VERSIONS-FRAGMENTS}} // "major feature bug hotfix fix"
```
