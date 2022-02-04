# Eze Github Action

Eze is the one stop solution developed by RiverSafe Ltd for security testing in modern development.

This is a Github Action for executing [Eze](https://hub.docker.com/r/riversafe/eze-cli) security tool in your repository, that scans for vulnerable dependencies, insecure code, hardcoded secrets, and license violations across a range of languages.

Supported languages are: Python, Node and Java.

Features:

- SAST tools for finding security anti-patterns
- SCA tools for finding vulnerable dependencies
- Secret tools for finding hardcoded passwords
- SBOM tools for generating a list of components

You can use more advanced features in the **`Eze Console`**, a web interface we have designed to monitor the security of all your repos.


## Example Usage


Check [action.yml](action.yml) for documentation

Set the job inside a workflow, you can get a template and replace as needed. And you will need to set a config file for Eze to run based on the language your code is in and the security scans you want to perform.

### Input files
- To run Eze in your repo you will need a config file called `.ezerc.toml` to specify which tools to run based on the language on your repo, for more info check [here](https://github.com/RiverSafeUK/eze-cli/tree/develop/examples).

### Input parameters

- upload_method: The method chosen by the user to handle Eze results ('sarif' or 'markdown')

### Output parameters

- sarif_file: Report file generated by Eze as sarif format (required for sarif workflow)
- markdown_file: Report file generated by Eze as markdown format required for markdown workflow)

### Simple usage:

```yaml
uses: RiverSafeUK/eze-docker-action@main
with:
    # The format to export the test results file ('sarif' or 'markdown')
    upload_method: sarif  
id: eze-test
```

### Full Workflow Example for Markdown
---
```yaml
on:
  push: 
    branches: 
      - main
      - develop

jobs:
  eze-test:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    name: Eze Security Test
    steps:
      - name: Checkout repository code
        uses: actions/checkout@v2
      - name: Testing with Eze - markdown
        uses: RiverSafeUK/eze-docker-action@main
        with: 
          upload_method: markdown
        id: eze-test
      - name: Write markdown to workspace file.
        run: |
          cat > eze.md <<'EOF'
            ${{ steps.eze-test.outputs.markdown_file }}
          EOF
          cat eze.md
      - name: Commit files
        run: |
          git add eze.md && \
          git config --local user.email "github-actions[bot]@users.noreply.github.com" && \
          git config --local user.name "github-actions[bot]" && \
          git commit -m "Update security report" -a || \
          echo No diff
      - name: Push changes
        uses: ad-m/github-push-action@master
        with:
          branch: ${{ github.ref }}
```


### Full Workflow Example for Sarif
---
```yaml
on:
  push: {branches: main}
  pull_request: {branches: main}

jobs:
  eze-test:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    name: Eze Security Test
    steps:
      - name: Checkout repository code
        uses: actions/checkout@v2
      - name: Testing with Eze - sarif
        uses: RiverSafeUK/eze-docker-action@main
        with: 
          upload_method: sarif
        id: eze-test
      - name: Write sarif to workspace file.
        run: |
          cat > eze.sarif <<'EOF'
            ${{ steps.eze-test.outputs.sarif_file }}
          EOF
      - name: Upload SARIF report
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: eze.sarif
          category: my-analysis-tool
```


## Output reports


With Eze action you can choose from the 2 output report formats below, by customising your workflow:


### Sarif
Recommended for public repos or private repos with Github Enterprise license

Eze scan will generate a SARIF report that can be viewed in the `Security` tab of your repo.

<details>
<summary>Example</summary>

```sarif
{
    "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
    "version": "2.1.0",
    "runs": [
      {
        "tool": {
          "driver": {
            "name": "python-piprot",
            "version": "3.1",
            "fullName": "SCA:python-piprot",
            "informationUri": "https://pypi.org/project/piprot/",
            "rules": [
              {
                "id": "e59e7309-20ba-4270-8cdc-9ff963a8e8aa",
                "name": "requests",
                "shortDescription": {
                  "text": "<short_description>"
                },
                "fullDescription": {
                  "text": "requests (2.4.0) is 2686 days out of date. Latest is 2.27.1. requests (2.4.0) 2686 days out of date. update to a newer version, latest version: 2.27.1"
                }
              }
            ]
          }
        },
        "results": [
          {
            "ruleId": "e59e7309-20ba-4270-8cdc-9ff963a8e8aa",
            "ruleIndex": 0,
            "level": "error",
            "message": {
              "text": "requests (2.4.0) 2686 days out of date. update to a newer version, latest version: 2.27.1"
            },
            "locations": [
              {
                "physicalLocation": {
                  "artifactLocation": {
                    "uri": "unknown"
                  },
                  "region": {
                    "startLine": 1
                  }
                }
              }
            ]
          }
        ],
        "taxonomies": []
      },
      {
        "tool": {
          "driver": {
            "name": "python-cyclonedx",
            "version": "unknown",
            "fullName": "SBOM:python-cyclonedx",
            "informationUri": "https://cyclonedx.org/",
            "rules": [
              {
                "id": "31451cce-9f74-4a18-8b1e-231cae677fb0",
                "name": "pip",
                "shortDescription": {
                  "text": "<short_description>"
                },
                "fullDescription": {
                  "text": "The pip package before 19.2 for Python allows Directory Traversal when a URL is given in an install command"
                }
              }
            ]
          }
        },
        "results": [
          {
            "ruleId": "31451cce-9f74-4a18-8b1e-231cae677fb0",
            "ruleIndex": 0,
            "level": "error",
            "message": {
              "text": "Update package to non-vulnerable version 19.2"
            },
            "locations": [
              {
                "physicalLocation": {
                  "artifactLocation": {
                    "uri": "requirements.txt"
                  },
                  "region": {
                    "startLine": 1
                  }
                }
              }
            ]
          }          
        ],
        "taxonomies": []
      }
    ]
 }
 ```
</details>

<br/>

### Markdown 
Recommended for private repos with Github Free

Eze scan will generate a markdown report that will be uploaded directly to your working branch. 

<details>
<summary>Example</summary>


# Eze Report Results


## Summary  ![tools](https://img.shields.io/static/v1?style=plastic&label=Tools_executed&message=5&color=blue)
---

Branch tested: main


![critical](https://img.shields.io/static/v1?style=plastic&label=critical&message=0&color=red)
![high](https://img.shields.io/static/v1?style=plastic&label=high&message=3&color=orange)
![medium](https://img.shields.io/static/v1?style=plastic&label=medium&message=7&color=yellow)
![low](https://img.shields.io/static/v1?style=plastic&label=low&message=2&color=lightgrey)
            

## Vulnerabilities
---


    [python-piprot] Vulnerabilities
    =================================
    TOOL REPORT: [github] python-piprot (scan duration: 0.3 seconds)
        total: 1 (high:1)
        ignored: 1 (none:1)

        [HIGH DEPENDENCY] : requests (2.4.0)
        overview: requests (2.4.0) is 2686 days out of date. Latest is 2.27.1
        recommendation: requests (2.4.0) 2686 days out of date. update to a newer version, latest version: 2.27.1

        [NONE DEPENDENCY] : requests (2.4.0)
        overview: requests (2.4.0) is 2686 days out of date. Latest is 2.27.1
        recommendation: update requests (2.4.0) to a newer version, current version is 23 minor versions out of date. Latest is 2.27.1

</details>