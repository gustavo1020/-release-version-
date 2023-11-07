 # V1
This action automates the process of creating version tags for different branches in your project. It ensures that the new tag is generated based on the latest tag in the branch and the label of the most recent PR that has been merged. In other words, it keeps track of the project's versioning and labels, making it easier to manage and understand the project's history and changes.

Add the top 5 labels to your repository with their respective names.

![image](https://github.com/gustavo1020/-release-version-/blob/main/img/Screenshot%202023-11-02%20172203.png)


Using the labels from your repository, set them as secrets in GitHub in the following order: ej the secret = "major feature bug hotfix fix"
- "major" (major change)
- "feature" (new feature)
- "bug" (software error, regardless of whether it's in production or pre-production)
- "hotfix" (error in a feature requested in production)
- "fix" (error in a feature requested in pre-production)

It prioritizes having only 1 tag of the 5 declared and one that says release (the latter is mandatory for the generation of the tag), if it contains others that are not in the previous list, that is not a problem.

:fire:

![image](https://github.com/gustavo1020/-release-version-/blob/main/img/Screenshot%202023-11-02%20173734.png)

:white_check_mark:

![image](https://github.com/gustavo1020/-release-version-/blob/main/img/image.png)

:fire:

![image](https://github.com/gustavo1020/-release-version-/blob/main/img/Screenshot%202023-11-02%20173845.png)

```yaml
steps:

  - name: Print release versio
    id: bump_version
    uses: gustavo1020/-release-version-@v1.0.0-stable
    with:
      list-version-fragment: ${{secret.LIST-VERSIONS-FRAGMENTS}} // "major feature bug hotfix fix"
      //optional
      prefix: 'v' //ej v1.0.1-stable
      // generar tag cuando el PR tenga un tag que sea release
      // pendiente si label del PR viene sin nada avisar con un error (y modificar las formas de modificar el beta y stable al generar el tag)
      
  - name: Print release version
    run: echo ${{ steps.bump_version.outputs.next-version }}
```

```
| version-label-PR | latest-version-branch |   | output          |
| ---------------- | --------------------- | - | --------------- |
| major            | 2.11.7-stable         |   | 3.0.0-stable    |
| major            | 2.11.7-beta           |   | 3.0.0-beta      |
| feature          | 2.11.7-stable         |   | 2.12.0-stable   |
| feature          | 2.11.7-beta           |   | 2.12.0-beta     |
| bug              | 2.11.7-stable         |   | 2.11.8-stable   |
| bug              | 2.11.7-beta           |   | 2.11.8-beta     |
| hotfix           | 2.11.7-hotfix.1       |   | 2.11.7-hotfix.2 |
| hotfix           | 2.11.7                |   | 2.11.7-hotfix.1 |
| fix              | 2.11.7-beta.1         |   | 2.11.7-beta.2   |
| fix              | 2.11.7-beta           |   | 2.11.7-beta.1   |
```
