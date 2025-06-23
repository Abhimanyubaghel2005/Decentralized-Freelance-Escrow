pragma solidity ^0.8.17;

contract FreelanceEscrow {
    struct Project {
        uint256 id;
        address client;
        address freelancer;
        uint256 amount;
        string description;
        bool completed;
        bool disputed;
        uint256 createdAt;
    }
    
    mapping(uint256 => Project) public projects;
    mapping(address => uint256[]) public clientProjects;
    mapping(address => uint256[]) public freelancerProjects;
    
    uint256 public projectCounter;
    uint256 public constant DISPUTE_FEE = 0.01 ether;
    
    event ProjectCreated(uint256 indexed projectId, address indexed client, address indexed freelancer, uint256 amount);
    event ProjectCompleted(uint256 indexed projectId);
    event DisputeRaised(uint256 indexed projectId);
    event FundsReleased(uint256 indexed projectId, address indexed recipient, uint256 amount);
    
    modifier onlyClient(uint256 _projectId) {
        require(projects[_projectId].client == msg.sender, "Only client can call this");
        _;
    }
    
    modifier onlyFreelancer(uint256 _projectId) {
        require(projects[_projectId].freelancer == msg.sender, "Only freelancer can call this");
        _;
    }
    
    function createProject(address _freelancer, string memory _description) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_freelancer != address(0), "Invalid freelancer address");
        
        projectCounter++;
        
        projects[projectCounter] = Project({
            id: projectCounter,
            client: msg.sender,
            freelancer: _freelancer,
            amount: msg.value,
            description: _description,
            completed: false,
            disputed: false,
            createdAt: block.timestamp
        });
        
        clientProjects[msg.sender].push(projectCounter);
        freelancerProjects[_freelancer].push(projectCounter);
        
        emit ProjectCreated(projectCounter, msg.sender, _freelancer, msg.value);
    }
    
    function completeProject(uint256 _projectId) external onlyFreelancer(_projectId) {
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        require(!project.disputed, "Project is disputed");
        
        project.completed = true;
        
        emit ProjectCompleted(_projectId);
    }
    
    function releaseFunds(uint256 _projectId) external onlyClient(_projectId) {
        Project storage project = projects[_projectId];
        require(project.completed, "Project not completed");
        require(!project.disputed, "Project is disputed");
        
        uint256 amount = project.amount;
        project.amount = 0;
        
        payable(project.freelancer).transfer(amount);
        
        emit FundsReleased(_projectId, project.freelancer, amount);
    }
    
    function raiseDispute(uint256 _projectId) external payable {
        Project storage project = projects[_projectId];
        require(msg.sender == project.client || msg.sender == project.freelancer, "Only project participants can raise dispute");
        require(!project.disputed, "Dispute already raised");
        require(msg.value >= DISPUTE_FEE, "Insufficient dispute fee");
        
        project.disputed = true;
        
        emit DisputeRaised(_projectId);
    }
    
    function getProject(uint256 _projectId) external view returns (Project memory) {
        return projects[_projectId];
    }
}