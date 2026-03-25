
<a id="readme-top"></a>

<div align="center">
  
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

</div>

<!-- PROJECT LOGO -->

<div align="center">
  <a href="https://github.com/Mazharul419/ECS-Forge">
  </a>


<h3 align="center">ECS-Forge</h3>

<img src="https://github.com/user-attachments/assets/1dfdb3d9-8b23-407f-9f94-336233fdf405">

  <p align="center">
    An End-to-End deployment of the code-server application hosted on ECS Fargate
    <br />
    <a href="https://github.com/Mazharul419/ECS-Forge"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Mazharul419/ECS-Forge/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/Mazharul419/ECS-Forge/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>


### 👇 View Demo 👇
https://www.loom.com/share/2402051f736d492990df21803c33065a
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



## Built With

#### Application setup:

[![Linux][Linux]][Linux-url]
[![Docker][Docker]][Docker-url]
<br>
#### DNS/Cloud Infrastructure:

[![CloudFlare][CloudFlare]][CloudFlare-url] 
[![AWS][AWS]][AWS-url]
<br>
#### Infrastructure-As-Code:

[![Terraform][Terraform.io]][Terraform-url]
[![Terragrunt][Terragrunt.io]][Terragrunt-url]
[![HCL][HCL]][HCL-url]
<br>
#### Version Control and CI/CD:

[![Git][Git]][Git-url]
[![Github Actions][Github Actions]][Github Actions-url]
[![YAML][YAML]][YAML-url]
<br>

#### Additional Scripting Languages:

[![Bash][Bash]][Bash-url]
[![Python][Python]][Python-url]




<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Application

### Dev Environment
<img width="1913" height="999" alt="image" src="https://github.com/user-attachments/assets/fde6559b-4eee-49c9-8fd5-c580f5c61cc7" />

### Prod Environment
<img width="1918" height="995" alt="image" src="https://github.com/user-attachments/assets/5ec9349d-573a-43a5-afc1-e5428d1b801e" />

## Pipelines

### Terragrunt Deploy
deploy_environment.yaml
<img width="1910" height="985" alt="image" src="https://github.com/user-attachments/assets/9496ab93-9af3-4c91-a4ab-236d49e556b8" />

### Build and Push Docker image
build_push_image.yaml
<img width="1888" height="555" alt="image" src="https://github.com/user-attachments/assets/17c2cf1f-dd24-4907-a049-4d3d49666265" />

### Update image
deploy_image.yaml
<img width="1905" height="931" alt="image" src="https://github.com/user-attachments/assets/1b78891e-2a17-4c8f-a99b-4947111a5270" />

### Terragrunt Destroy
destroy_environment.yaml
<img width="1897" height="954" alt="image" src="https://github.com/user-attachments/assets/16e75764-5676-4363-9414-11e2f0c2ffd0" />


<!-- GETTING STARTED -->
## Getting Started

This is how you can set up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

For the scripts annd infrastructure to run you need minimum the following:

* Terraform version 1.14.1
* Terragrunt 0.93.13**
* AWS cli 2.32.6 - should connect to AWS account with Admin credentials
* Python 3.12.3
* GNU bash 5.2.21
* Git 2.43.0
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
   This creates an S3 bucket for the terraform state, an ECR Repo and Github Actions OIDC role for infrastructure to be deployed!
    
6. Go to Github actions and run the "Terragrunt Deploy" workflow:
   <img width="1883" height="400" alt="image" src="https://github.com/user-attachments/assets/ba53c3f1-d859-4b00-8481-da8bd1ffb10f" />


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This project is useful for someone looking to go deep into learning Devops practices = amd understanding trade-offs and fundemental CI CD pipelines ensuring devs can ship code with ease. 

Additional screenshots, code examples and demos to be added as per roadmap below!


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Complete documentation for code 
- [ ] Architectural decisions doc
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

### CoderCo for providing the assignment, knowledge and community for me to complete this!
###  

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
[license-url]: https://github.com/Mazharul419/ECS-Forge/tree/main?tab=MIT-1-ov-file
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
[HCL]: https://img.shields.io/badge/HCL-844FBA?style=for-the-badge&logo=terraform&logoColor=fff 
[HCL-url]: https://developer.hashicorp.com/terraform/language
[YAML]: https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=fff
[YAML-url]: https://yaml.org/
[Docker]: https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=fff
[Docker-url]: https://getbootstrap.com
[AWS]: https://custom-icon-badges.demolab.com/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=aws&logoColor=white
[AWS-url]: https://aws.amazon.com/
[CloudFlare]: https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white
[CloudFlare-url]: https://www.cloudflare.com/en-gb/
[Github Actions]: https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white 
[Github Actions-url]: https://github.com/features/actions
[Git]: https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=fff
[Git-url]: https://git-scm.com/
[Linux]: https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black
[Linux-url]: https://www.linux.org/
