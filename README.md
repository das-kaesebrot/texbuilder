# Usage

Run the container:

```bash
docker run --rm -v "$PWD":/var/opt/texproject -it daskaesebrot/texbuilder
```

Then execute your commands inside the container.

## GitLab CI/CD

```yaml
stages:
  - build

variables:
  # main latex file without .tex extension
  TEX_MAIN_FILE: your-main-file
  TLMGR_BACKUP_DIR: tlmgr-pkgs

build-latex:
  stage: build
  image: daskaesebrot/texbuilder
  rules:
    - changes:
        - "**/*.tex"
        - "assets/*"
        - "**/*.bib"
        - .gitlab-ci.yml
      when: always
    - when: never
  script:
    - tlmgr restore --force --backupdir $TLMGR_BACKUP_DIR --all || true
    - texliveonfly --compiler=xelatex --arguments="-shell-escape -interaction=nonstopmode" $TEX_MAIN_FILE
    - biber $TEX_MAIN_FILE
    - texliveonfly --compiler=xelatex --arguments="-shell-escape -interaction=nonstopmode" $TEX_MAIN_FILE
    - texliveonfly --compiler=xelatex --arguments="-shell-escape -interaction=nonstopmode" $TEX_MAIN_FILE
    - test -d $TLMGR_BACKUP_DIR && tlmgr backup --clean --backupdir $TLMGR_BACKUP_DIR --all || mkdir -p $TLMGR_BACKUP_DIR
    - tlmgr backup --backupdir $TLMGR_BACKUP_DIR --all
  artifacts:
    paths:
      - "*.pdf"
      - "*.log"
  cache:
    - key: "$CI_JOB_NAME-tlmgr"
      paths:
        - "$TLMGR_BACKUP_DIR/"

```