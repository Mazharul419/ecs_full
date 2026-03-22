
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
<div align="center">
  
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Mazharul419/ECS-Forge">
<img width="1160" height="911" alt="image" src="https://github.com/user-attachments/assets/d45b94af-536c-4fa1-a785-0e9d365bdfc2" />
  </a>



<h3 align="center">ECS-Forge</h3>

  <p align="center">
    An End-to-End deployment of the code-server application hosted on ECS Fargate
    <br />
    <a href="https://github.com/Mazharul419/ECS-Forge"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Mazharul419/ECS-Forge">View Demo</a>
    &middot;
    <a href="https://github.com/Mazharul419/ECS-Forge/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/Mazharul419/ECS-Forge/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

This is an end-to-end deployment of the code-server application via ECS Fargate. Upon push to main, or on successful pull request - a Docker image of the application is automatically built and pushed to ECR - where via manual trigger in Github Actions, deployment to Dev and Prod environment (or both) takes place.

The application is hosted on AWS - hidden behind an application load balancer.

## Key Features
* 35% Cost reduction through use of VPC endpoints vs NAT Gateways
* Enhanced security posture using short-lived OIDC credentials
* App protected via intelligent routing through Application Load Balancer (ALB)
* 95% in Docker image size reduction through multi-stage builds
* Adherence to Don't-Repeat-Yourself (DRY) principle through Terragrunt deployment
* Secure remote state through S3 native locking

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

#### Infrastructure/IaC 
[![Terraform][Terraform.io]][Terraform-url]  [![Terragrunt][Terragrunt.io]][Terragrunt-url]
[![Docker][Docker]][Docker-url]
[![AWS][AWS]][AWS-url] [![CloudFlare][CloudFlare]][CloudFlare-url]

#### Languages

* [![Bash][Bash]][Bash-url]
* [![Python][Python]][Python-url]
* [![YAML][YAML]][YAML-url]

#### 

##

* [![][]][-url]
* [![][]][-url]
* [![][]][-url]
* [![][]][-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is how you can set up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

For the scripts annd infrastructure to run you need minimum the following:

* terraform version 1.14.1
* terragrunt 0.93.13**
* aws cli 2.32.6 - should connect to AWS account with Admin credentials
* python 3.12.3
* GNU bash 5.2.21
* git 2.43.0
* Cloudflare account with Domain and Hosted zone

**this is strict requirement since terragrunt newer versions intoduced breaking changes to naming convention, code will not work otherwise

Please refer to the respective stack websites for instructions for installation - alternatively listed in "Built with" section.

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/Mazharul419/ECS-Forge.git
   ```
2. Copy .env.example - rename to .env and set environment variables from Cloudflare tokens
   ```sh
   export TF_VAR_cloudflare_api_token="ABDCDEFGHIJKLMNOPQRSTUVWXYZ123456" > replace
   export CLOUDFLARE_ZONE_ID="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" > replace
   ```

   IMPORTANT - should be automatic but check to ensure .env is in your gitignore!
   
4. Run Boostrap script in `/infrastucture/bootstrap/bootstrap.sh`
   ```sh
   ./infrastucture/bootstrap/bootstrap.sh
   ```
5. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin Mazharul419/ECS-Forge
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This project is useful for someone looking to go deep into learning Devops practices = amd understanding trade-offs and fundemental CI CD pipelines ensuring devs can ship code with ease. 

Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Complete documentation for code 
- [ ] Architetural decisions doc
- [ ] Add shell environment to Docker image
- [ ] Add healthcheck to Dockerfile
- [ ] + Many more

See the [open issues](https://github.com/Mazharul419/ECS-Forge/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors:

<a href="https://github.com/Mazharul419/ECS-Forge/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Mazharul419/ECS-Forge" alt="contrib.rocks image" />
</a>



<!-- LICENSE -->
## License

Distributed under the project_license. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - mazharulislam419@gmail.com.com

Project Link: [https://github.com/Mazharul419/ECS-Forge](https://github.com/Mazharul419/ECS-Forge)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Mazharul419/ECS-Forge.svg?style=for-the-badge
[contributors-url]: https://github.com/Mazharul419/ECS-Forge/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Mazharul419/ECS-Forge.svg?style=for-the-badge
[forks-url]: https://github.com/Mazharul419/ECS-Forge/network/members
[stars-shield]: https://img.shields.io/github/stars/Mazharul419/ECS-Forge.svg?style=for-the-badge
[stars-url]: https://github.com/Mazharul419/ECS-Forge/stargazers
[issues-shield]: https://img.shields.io/github/issues/Mazharul419/ECS-Forge.svg?style=for-the-badge
[issues-url]: https://github.com/Mazharul419/ECS-Forge/issues
[license-shield]: https://img.shields.io/github/license/Mazharul419/ECS-Forge.svg?style=for-the-badge
[license-url]: https://github.com/Mazharul419/ECS-Forge/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/mazharul419
[product-screenshot]: images/screenshot.png
<!-- Shields.io badges. You can a comprehensive list with many more badges at: https://github.com/inttter/md-badges -->
[Terraform.io]: https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=fff
[Terraform-url]: https://developer.hashicorp.com/terraform
[Terragrunt.io]: https://img.shields.io/badge/Terragrunt-DDE072?style=for-the-badge&logo=terraform&logoColor=black
[Terragrunt-url]: https://terragrunt.com/
[Python]: https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white
[Python-url]: https://www.python.org/
[Bash]: https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white
[Bash-url]: https://www.gnu.org/software/bash/
[HCL]: https://img.shields.io/badge/HCL-006BB6?style=for-the-badge&logo=hcl&logoColor=white 
[HCL-url]: https://developer.hashicorp.com/terraform/language
[YAML]: https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=fff
[YAML-url]: https://yaml.org/
[Docker]: https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=fff
[Docker-url]: https://getbootstrap.com
[AWS]: https://custom-icon-badges.demolab.com/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=aws&logoColor=white
[AWS-url]: https://aws.amazon.com/
[CloudFlare]: https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white
[CloudFlare-url]: https://www.cloudflare.com/en-gb/
[]: 
[-url]: 
[]: 
[-url]: 
[]: 
[-url]: 
[]: 
[-url]: 
