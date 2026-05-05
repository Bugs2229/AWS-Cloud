prelims:
- discuss user data shell script
- discuss terminology used that day
    - discuss data centers
- discuss architecture diagram
- begin lab

lab:
1) sign into AWS console
2) go to or check you are in us-east-2 (why?)
3) go to EC2 dashboard
4) SG creation with only HTTP rule (explain why default HTTP is just for speed)
    - Left pane
    - Network and Security -> Security Groups
    - Create Security Group
    - SG Name, Description
    - Verify VPC is default
    - Add inbound HTTP with anywhere IPv4 source
    - Dont mess with outbound, verify all traffic is allowed
    - Mention tags
    - Create SG
    - Verify SG is created and correctly configured
5) Grab startup script
    - could be mine, their's, Theos, dont care
    - Show mookiewaf and mine
    - copy from GH
6) VM spinup 
    - left pane, Instances -> Instances
    - Launch Instances 
    - name, add some tags
    - discuss AMI menu, ensure defaults, collapse
    - discuss Instance type menu, ensure proper sizing, collapse
    - don't discuss key pair, select none, collapse
    - discuss networking settings menu
        - dont click edit
        - verify VPC, why subnet is not important, auto-assign public IP
        - select SG (not launch wizard!)
        - collapse
    - discuss configure storage menu, whats EBS, collapse
    - open Advanced settings, focus on one thing: user data, ignore the rest
    - review
    - launch instance
7) allow initalization, why does it take so long
8) test public DNS, discuss common issues
    - not formatting DNS address properly to ensure no HTTPS redirect, try a different browser too
    - improperly configured or no SG
    - no user data or improperly copy/paste
    - editing SG while instance is spun up without detaching (AWS bug?)
    - older AWS account with edited default VPC
9) change instance state, show resources that are still allocated
10) teardown 