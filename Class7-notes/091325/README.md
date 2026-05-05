# Notes for Class 7 - Saturday, September 13th, 2025
## Introduction to EC2 and Simple Web Server Deployment

---

## Table of Contents

- [Overview and Goals](#overview-and-goals)
- [Notes, Terminology, and Resources](#notes-terminology-and-resources)
- [Architecture](#architecture)
- [Scripts](#scripts)
- [Lab Instructions](#lab-instructions)
- [Deliverables](#deliverables)
- [Troubleshooting](#troubleshooting)
- [Teardown](#teardown)

---

## Overview and Goals

In this class, we will conduct a high-level discussion of AWS Elastic Compute Cloud (EC2) while lightly touching on essential networking concepts. We'll cover key terminology, discuss the desired architecture for our lab, and review the shell script we'll be using. Finally, we'll discuss the expected deliverables, complete the lab, and finish with troubleshooting and teardown procedures.

---

## Notes, Terminology, and Resources

### AWS Global Infrastructure
*The physical data centers where AWS resources "in the cloud" actually exist.*

AWS global infrastructure is spread throughout the world and coupled together with dedicated (but not necessarily Amazon-owned) network infrastructure. *Note: China and GovCloud are exceptions for inter-regional networking connections.*

**Key characteristics:**
- Has dedicated engineering, support, compliance, and security teams on-site
- Follows strict compliance and physical security requirements that CSPs (Cloud Service Providers, aka public cloud) must adhere to:

**Compliance Frameworks:**
- **Governmental:** FedRAMP, DoD IL4/IL5
- **Industry-specific:** HIPAA, PCI DSS
- **Regional laws:** GDPR, CCPA
- **General security:** NIST CSF, SP 500-292, SP 800-145, SP 800-171
- **Operational controls:** SOC 1/2/3 reports
- **Physical security:** ISO 27001/27002

**Infrastructure Hierarchy:**

**Regions:** Broad geographic areas with multiple availability zones
- **100% isolation** from other regions
- Contain multiple Availability Zones
- *Examples:* `us-east-1` (N. Virginia), `ap-northeast-1` (Tokyo)
- **Standard format:** `<geographic-area>-<subarea>-<region-number>` (all lowercase)

**Availability Zones (AZs):** Groups (or sometimes single) of tightly coupled physical data centers
- Often called *AZs* or *Zones*
- A letter is appended to the region to denote specific AZs (e.g., `us-west-1a`)
- One data center failure in an AZ can affect another data center in that AZ (*full isolation is not present*)
- AZs have much faster connections between data centers, meaning resources in different data centers have effectively no latency

**Further Reading:**
- [Basics of AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/?ref=wellarchitected)
- [AWS EC2 Infrastructure Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-regions)

---

### AWS EC2 (Amazon Web Services Elastic Compute Cloud)
*The AWS service that provides compute resources*

**Key Concepts:**
- Uses virtualization to create smaller units of computers, but always runs on physical hardware
- Provides **vCPU** (processing), **memory** (fast, temporary storage for computations), and **block storage** (EBS - essentially hard drives and SSDs for longer-term storage)
- Follows the **IaaS** (Infrastructure as a Service) cloud delivery model
- *You get the "computer" and are responsible for everything else: security, configuration, OS choice, scaling, etc.*

**Terminology:** Individual "computers" created by EC2 can be called several roughly synonymous terms:
- **EC2 Instance:** A specific computer provisioned by EC2 for us
- **Server:** A broader term for computers used to provide services to others (like web servers)
- **Virtual Machine (VM):** A computer created using virtualization via a hypervisor
- *Sometimes we may just call it an "instance" or "EC2" - while not technically precise, everyone understands the meaning*

**Important Characteristics:**
- EC2 Instances are **Zonal Resources**- they exist in specific AZs, not regions
- An EC2 instance could never be in `us-east-1`, but it could be in `us-east-1a`
- Many other AWS services run on EC2 "behind the scenes"

**Common Terms:**
- **AMI:** Amazon Machine Image- a pre-made template for a computer's OS and basic programs
- **Instance Type:** Determines how much vCPU, memory, network performance, and possibly GPUs are allocated to the instance (*i.e., how powerful it is*)

**Resources:**
- [EC2 Concepts Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [What is Virtualization?](https://youtu.be/UBVVq-xz5i0?si=pStiIn8mJ6Yx11SI)

---

### Networking
*How we allow computers to connect with each other and control those connections*

*Everyone reading this is using a network right now - your phone and laptop are connected via WiFi.*

**Essential Networking Videos** *(recommended viewing for future networking topics):*
- [IP Addressing Basics](https://youtu.be/ThdO9beHhpA?si=kdPhivt1qRnLcsg_)
- [Public and Private IP Addresses](https://youtu.be/po8ZFG0Xc4Q?si=HJyFxl20qmPsK-MX)
- [Basic Types of Networking Constructs](https://youtu.be/NyZWSvSj8ek?si=s6drYqB8bDdfAE59)
- [Subnet Masking](https://youtu.be/s_Ntt6eTn94?si=aSAZljgumahF4K7J)
- [Network Ports Introduction](https://youtu.be/g2fT-g9PX9o?si=OFEu-K25pCq73Mbg)
- [HTTP vs HTTPS](https://youtu.be/hExRDVZHhig?si=7YJkO6n8vfT1QkL0)

**VPC (Virtual Private Cloud):** *Virtual networks for your compute resources*
- Your own private chunk of AWS reserved for your resources - only you can access it
- Very similar in concept to your home network, but for cloud resources
- Serves as a virtual network for EC2 instances to communicate with each other and the internet
- *We've been using the Default VPC, but usually we'll create our own*
- **Regional Resources** - exist in regions (like `us-east-1`) and cannot span multiple regions
- *Terms "VPC" and "network" can be used interchangeably in AWS*

**Resources:**
- [AWS VPC Definition](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Simple VPC Explanation with Animations](https://www.youtube.com/watch?v=2fPgKvDBfbs)

**Subnets:** *The smaller units of a network (subnetworks)*
- All networks (including home networks and VPCs) use subnets
- Allow us to segment networks into smaller, manageable pieces as they can become quite complex
- Enable control over what resources can communicate with each other (e.g., NACLs)
- Control which resources can access the internet and which cannot

**Security Groups:** *Virtual firewalls for EC2 instances and other resources inside a VPC*
- Provide network security- we only want certain communications to occur
- *Technical note: They are L3/L4 protocol firewalls with L5 awareness for stateful connections*
- **Regional resources** scoped to specific VPCs
  - *A security group in one VPC cannot be used in another*
  - *Example: SG-A in VPC-1 cannot be used by the default VPC*
- Cannot control traffic for certain services (Amazon DNS, AWS DHCP, IMDS, time sync service, etc.)

**Resources:**
- [Security Group Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)
- [What is a Firewall?](https://youtu.be/kDEX1HXybrU?si=RFpE2EU_Y5gSzVOz)

---

## Architecture

![Architecture Diagram](./assets/best-ec2.png)

---

## Scripts

We'll use a shell script for bootstrapping the EC2 instance. It will configure the instance as a web server and handle other setup tasks. I have both simplified and extensively commented versions of the script (they perform the same functions) that are essentially the same as Theo's script.

We use one of these scripts in the EC2 instance's **user data** section.

### What is a Script?

A script is simply a list of instructions we give a computer via the CLI (Command Line Interface). It allows us to automate tasks and control behavior precisely.

Today, the "language" we use is typically called **bash**.

### Terminology

- **User Data:** Where we can tell the EC2 instance's OS (Linux only) what we want it to do when initially created *(AWS-specific term)*
- **Shell Script:** A broader term referring to a list of instructions that a computer's shell handles
- **Startup Script:** A script designed to set up a computer/server
- **Bootstrapping:** The process of setting up a server with a startup script *(has other uses in IT as well)*

### Script Options

- [My Simple Script](./scripts/simple_metadata.sh)
- [My Script with Extensive Comments](./scripts/annotated_metadata.sh)
- [Theo's Standard Script](https://github.com/MookieWAF/bmc4/blob/main/ec2scrpit)
- [Script for Making Fun of Theo](https://github.com/aaron-dm-mcdonald/theo-website/blob/main/startup.sh)

---

## Lab Instructions

### Prerequisites
1. Sign into the AWS Console
2. Verify the region you are using
3. Navigate to the EC2 Dashboard

### Step 1: Security Group Creation
*Create a security group with only an HTTP rule*

1. **Navigate to Security Groups:**
   - Left pane → Network and Security → Security Groups
   
2. **Create Security Group:**
   - Click "Create Security Group"
   - Enter SG Name and Description
   - Verify VPC is set to default
   - Add inbound HTTP rule with "Anywhere IPv4" source (`0.0.0.0/0`)
   - **Don't modify outbound rules** - verify "All traffic" is allowed
   - *(Optional: Add tags)*
   - Click "Create Security Group"
   
3. **Verification:**
   - Verify SG is created and correctly configured

### Step 2: Obtain Startup Script
- Choose from the available scripts (mine, yours, or Theo's)
- Copy the script from GitHub

### Step 3: Launch EC2 Instance

1. **Navigate to Instances:**
   - Left pane → Instances → Instances
   - Click "Launch Instances"

2. **Configure Instance:**
   - **Name and Tags:** Enter instance name, add relevant tags
   - **AMI Selection:** Review AMI menu, ensure defaults are selected, collapse
   - **Instance Type:** Review instance type menu, ensure proper sizing, collapse
   - **Key Pair:** Select "Proceed without key pair", collapse
   
3. **Network Settings:**
   - **Don't click "Edit"**
   - Verify VPC selection
   - *Note: Subnet selection is not critical for this lab*
   - Ensure "Auto-assign public IP" is enabled
   - **Select your created Security Group** *(NOT "launch-wizard"!)*
   - Collapse section
   
4. **Storage Configuration:**
   - Review Configure Storage menu
   - *Brief discussion: What is EBS?*
   - Collapse section
   
5. **Advanced Settings:**
   - Open Advanced Settings
   - **Focus on User Data section only** - ignore everything else
   - Paste your chosen startup script
   
6. **Launch:**
   - Review configuration
   - Click "Launch Instance"

### Step 4: Test Your Web Server

1. Wait for the instance to pass status checks
2. Copy the instance's **public DNS address**
3. Open your web browser
4. Navigate to: `http://<public-DNS-address>`
   - **Important:** Use `http://` prefix, not `https://`

---

## Deliverables

1) Working hyperlink delivered in the chat. If I can't click on it then it isn't correct. 

2) Screenshot of EC2 Instance in "stopped" state. 

---

## Troubleshooting

*Listed in order from most likely to least likely causes:*

### 1. **URL Issues** *(Most Common)*
- **Missing Protocol:** You forgot to put `http://` in front of the public DNS address
  - *Without the prefix, modern browsers redirect to HTTPS (port 443 instead of 80)*
- **Wrong DNS Address:** You're using the private DNS address instead of public
  - *Private DNS only works inside the VPC*
- **Correct format:** `http://<public-DNS>`

### 2. **Security Group Configuration**
- Does your EC2 instance have a Security Group assigned?
- Does the assigned SG have an **inbound (ingress) rule** for HTTP (port 80 TCP) with IPv4 source from anywhere (`0.0.0.0/0`)?
- Does the **outbound rule** exist and permit all ports and protocols?

### 3. **User Data Script Issues**
- You incorrectly copied and pasted the user data/startup script
- You may have forgotten to copy/paste it entirely

### 4. **Less Likely Issues:**
- **Wrong VPC:** You're using an incorrect VPC
- **Broken Default VPC:** You deleted the Internet Gateway (IGW) or edited the Route Tables (RTBs)
- **No Public IP:** You disabled the auto-assign public IP feature
- **Security Group Editing:** You edited the SG without first removing it from the EC2 instance

---

## Teardown


1. **Terminate the EC2 Instance**
   - Navigate to EC2 → Instances
   - Select your instance
   - Instance State → Terminate Instance

2. **Delete Security Group** *(Optional)*
   - Navigate to EC2 → Security Groups
   - Select your created security group
   - Actions → Delete Security Group
   - *Note: Can only delete after instance termination*

---

*End of Class 7 Notes*