// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.2;
// pragma experimental ABIEncoderV2;
contract Property {
    struct Propertyreg {
        uint id;
        uint area;
        string city;
        string state;
        uint propertyPrice;
        uint propertyPID;
        uint physicalSurveyNumber;
        string ipfsHash;
        string document;
    }

    struct Buyer{
        address id;
        string name;
        uint age;
        string city;
        string aadharNumber;
        string panNumber;
        string document;
        string email;
    }

    struct Seller{
        address id;
        string name;
        uint age;
        string aadharNumber;
        string panNumber;
        string propertiesOwned;
        string document;
    }

    struct propertyInspector {
        uint id;
        string name;
        uint age;
        string designation;
    }

    struct PropertyRequest{
        uint reqId;
        address sellerId;
        address buyerId;
        uint propertyId;
        // bool requestStatus;
        // bool requested;
    }

    //key value pairs
    mapping(uint => Propertyreg) public Properties;
    mapping(uint => propertyInspector) public InspectorMapping;
    mapping(address => Seller) public SellerMapping;
    mapping(address => Buyer) public BuyerMapping;
    mapping(uint => PropertyRequest) public RequestsMapping;

    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredSellerMapping;
    mapping(address => bool) public RegisteredBuyerMapping;
    mapping(address => bool) public SellerVerification;
    mapping(address => bool) public SellerRejection;
    mapping(address => bool) public BuyerVerification;
    mapping(address => bool) public BuyerRejection;
    mapping(uint => bool) public propertyVerification;
    mapping(uint => address) public propertyOwner;
    mapping(uint => bool) public RequestStatus;
    mapping(uint => bool) public RequestedProperties;
    mapping(uint => bool) public PaymentReceived;

    address public property_Inspector;
    address[] public sellers;
    address[] public buyers;

    uint public propertyCount;
    uint public inspectorsCount;
    uint public sellersCount;
    uint public buyersCount;
    uint public requestsCount;

    event Registration(address _registrationId);
    event Addingproperty(uint indexed _propertyId);
    event propertyrequested(address _sellerId);
    event requestApproved(address _buyerId);
    event Verified(address _id);
    event Rejected(address _id);

    constructor() public{
        property_Inspector = msg.sender ;
        addpropertyInspector("Inspector 1", 45, "Tehsil Manager");
    }

    function addpropertyInspector(string memory _name, uint _age, string memory _designation) private {
        inspectorsCount++;
        InspectorMapping[inspectorsCount] = propertyInspector(inspectorsCount, _name, _age, _designation);
    }

    function getPropertysCount() public view returns (uint) {
        return propertyCount;
    }

    function getBuyersCount() public view returns (uint) {
        return buyersCount;
    }

    function getSellersCount() public view returns (uint) {
        return sellersCount;
    }

    function getRequestsCount() public view returns (uint) {
        return requestsCount;
    }
    function getArea(uint i) public view returns (uint) {
        return Properties[i].area;
    }
    function getCity(uint i) public view returns (string memory) {
        return Properties[i].city;
    }
     function getState(uint i) public view returns (string memory) {
        return Properties[i].state;
    }
    // function getStatus(uint i) public view returns (bool) {
    //     return properties[i].verificationStatus;
    // }
    function getPrice(uint i) public view returns (uint) {
        return Properties[i].propertyPrice;
    }
    function getPID(uint i) public view returns (uint) {
        return Properties[i].propertyPID;
    }
    function getSurveyNumber(uint i) public view returns (uint) {
        return Properties[i].physicalSurveyNumber;
    }
    function getImage(uint i) public view returns (string memory) {
        return Properties[i].ipfsHash;
    }
    function getDocument(uint i) public view returns (string memory) {
        return Properties[i].document;
    }
    
    function getpropertyOwner(uint id) public view returns (address) {
        return propertyOwner[id];
    }

    function verifySeller(address _sellerId) public{
        require(isPropertyInspector(msg.sender));

        SellerVerification[_sellerId] = true;
        emit Verified(_sellerId);
    }

    function rejectSeller(address _sellerId) public{
        require(isPropertyInspector(msg.sender));

        SellerRejection[_sellerId] = true;
        emit Rejected(_sellerId);
    }

    function verifyBuyer(address _buyerId) public{
        require(isPropertyInspector(msg.sender));

        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }

    function rejectBuyer(address _buyerId) public{
        require(isPropertyInspector(msg.sender));

        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }
    
    function verifyProperty(uint _propertyId) public{
        require(isPropertyInspector(msg.sender));
        propertyVerification[_propertyId] = true;
    }

    function isPropertyVerified(uint _id) public view returns (bool) {
        if(propertyVerification[_id]){
            return true;
        }
    }

    function isVerified(address _id) public view returns (bool) {
        if(SellerVerification[_id] || BuyerVerification[_id]){
            return true;
        }
    }

    function isRejected(address _id) public view returns (bool) {
        if(SellerRejection[_id] || BuyerRejection[_id]){
            return true;
        }
    }

    function isSeller(address _id) public view returns (bool) {
        if(RegisteredSellerMapping[_id]){
            return true;
        }
    }

    function isPropertyInspector(address _id) public view returns (bool) {
        if (property_Inspector == _id){
            return true;
        }else{
            return false;
        }
    }

    function isBuyer(address _id) public view returns (bool) {
        if(RegisteredBuyerMapping[_id]){
            return true;
        }
    }
    function isRegistered(address _id) public view returns (bool) {
        if(RegisteredAddressMapping[_id]){
            return true;
        }
    }

    function addProperty(uint _area, string memory _city,string memory _state, uint landPrice, uint _propertyPID,uint _surveyNum,string memory _ipfsHash, string memory _document) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        propertyCount++;
        Properties[propertyCount] = Propertyreg(propertyCount, _area, _city, _state, landPrice,_propertyPID, _surveyNum, _ipfsHash, _document);
        propertyOwner[propertyCount] = msg.sender;
        // emit AddingProperty(propertyCount);
    }

    //registration of seller
    function registerSeller(string memory _name, uint _age, string memory _aadharNumber, string memory _panNumber, string memory _propertiesOwned, string memory _document) public {
        //require that Seller is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredSellerMapping[msg.sender] = true ;
        sellersCount++;
        SellerMapping[msg.sender] = Seller(msg.sender, _name, _age, _aadharNumber,_panNumber, _propertiesOwned, _document);
        sellers.push(msg.sender);
        emit Registration(msg.sender);
    }

    function updateSeller(string memory _name, uint _age, string memory _aadharNumber, string memory _panNumber, string memory _propertiesOwned) public {
        //require that Seller is already registered
        require(RegisteredAddressMapping[msg.sender] && (SellerMapping[msg.sender].id == msg.sender));

        SellerMapping[msg.sender].name = _name;
        SellerMapping[msg.sender].age = _age;
        SellerMapping[msg.sender].aadharNumber = _aadharNumber;
        SellerMapping[msg.sender].panNumber = _panNumber;
        SellerMapping[msg.sender].propertiesOwned = _propertiesOwned;

    }

    function getSeller() public view returns( address [] memory ){
        return(sellers);
    }

    function getSellerDetails(address i) public view returns (string memory, uint, string memory, string memory, string memory, string memory) {
        return (SellerMapping[i].name, SellerMapping[i].age, SellerMapping[i].aadharNumber, SellerMapping[i].panNumber, SellerMapping[i].propertiesOwned, SellerMapping[i].document);
    }

    function registerBuyer(string memory _name, uint _age, string memory _city, string memory _aadharNumber, string memory _panNumber, string memory _document, string memory _email) public {
        //require that Buyer is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredBuyerMapping[msg.sender] = true ;
        buyersCount++;
        BuyerMapping[msg.sender] = Buyer(msg.sender, _name, _age, _city, _aadharNumber, _panNumber, _document, _email);
        buyers.push(msg.sender);

        emit Registration(msg.sender);
    }

    function updateBuyer(string memory _name,uint _age, string memory _city,string memory _aadharNumber, string memory _email, string memory _panNumber) public {
        //require that Buyer is already registered
        require(RegisteredAddressMapping[msg.sender] && (BuyerMapping[msg.sender].id == msg.sender));

        BuyerMapping[msg.sender].name = _name;
        BuyerMapping[msg.sender].age = _age;
        BuyerMapping[msg.sender].city = _city;
        BuyerMapping[msg.sender].aadharNumber = _aadharNumber;
        BuyerMapping[msg.sender].email = _email;
        BuyerMapping[msg.sender].panNumber = _panNumber;
        
    }

    function getBuyer() public view returns( address [] memory ){
        return(buyers);
    }

    function getBuyerDetails(address i) public view returns ( string memory,string memory, string memory, string memory, string memory, uint, string memory) {
        return (BuyerMapping[i].name,BuyerMapping[i].city , BuyerMapping[i].panNumber, BuyerMapping[i].document, BuyerMapping[i].email, BuyerMapping[i].age, BuyerMapping[i].aadharNumber);
    }


    function requestProperty(address _sellerId, uint _propertyId) public{
        require(isBuyer(msg.sender) && isVerified(msg.sender));
        
        requestsCount++;
        RequestsMapping[requestsCount] = PropertyRequest(requestsCount, _sellerId, msg.sender, _propertyId);
        RequestStatus[requestsCount] = false;
        RequestedProperties[requestsCount] = true;

        emit propertyrequested(_sellerId);
    }

    function getRequestDetails (uint i) public view returns (address, address, uint, bool) {
        return(RequestsMapping[i].sellerId, RequestsMapping[i].buyerId, RequestsMapping[i].propertyId, RequestStatus[i]);
    }

    function isRequested(uint _id) public view returns (bool) {
        if(RequestedProperties[_id]){
            return true;
        }
    }

    function isApproved(uint _id) public view returns (bool) {
        if(RequestStatus[_id]){
            return true;
        }
    }

    function approveRequest(uint _reqId) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
       
        RequestStatus[_reqId] = true;

    }

    function propertyOwnershipTransfer(uint _propertyId, address _newOwner) public{
        require(isPropertyInspector(msg.sender));

        propertyOwner[_propertyId] = _newOwner;
    }

    function isPaid(uint _propertyId) public view returns (bool) {
        if(PaymentReceived[_propertyId]){
            return true;
        }
    }

    function payment(address payable _receiver, uint _propertyId) public payable {
        PaymentReceived[_propertyId] = true;
        _receiver.transfer(msg.value);
    }


}