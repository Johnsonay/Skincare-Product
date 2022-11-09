// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SkincareProduct {

    uint internal productsLength = 0;
    
    //  address of the cusd token
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;


// struct containing product data
    struct Product {
        address payable owner;
        string brand;
        string image;
        string category;
        string deliveredWithin;
        uint numberOfStock;
        uint amount;
        uint sales;
    }

    // map product struck to an integer
    mapping (uint => Product) private products;
    
    // event to e triggered when product is ordered
    event ProductOrdered (
        address _from,
        uint productId
    );

    // To prevent to access permission from 3rd persons
    modifier isOwner(uint _index) {
        require(msg.sender == products[_index].owner, "NOT_OWNER");
        _;
    }
    

    /// @dev save a particular product to the blockchain
    /// @notice Input needs to contain only valid values
    function addProduct(
        string calldata _brand,
        string calldata _image,
        string calldata _category, 
        string calldata _deliveredWithin,
        uint _numberOfStock,
        uint _amount
    ) public {
        require(bytes(_brand).length > 0, "Empty brand");
        require(bytes(_image).length > 0, "Empty image");
        require(bytes(_category).length > 0, "Empty category");
        require(bytes(_deliveredWithin).length > 0, "Empty delivery date");
        require(_numberOfStock > 0, "Please enter a valid number of stock ");
        require(_amount > 0, "Please enter a valid amount");
        
        products[productsLength] = Product(
            payable(msg.sender),
            _brand,
            _image,
            _category,
            _deliveredWithin,
            _numberOfStock,
            _amount,
            0
        );
        productsLength++;
    }

    /// @dev get a particular product
    function getProduct(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory,
        uint, 
        uint,
        uint
    ) {
        Product storage p = products[_index];
        return (
            p.owner,
            p.brand, 
            p.image, 
            p.category, 
            p.deliveredWithin,
            p.numberOfStock, 
            p.amount,
            p.sales
        );
    }
    
    /// @dev  orders a product
    function orderProduct(uint _index) public payable  {
        Product storage currentProduct = products[_index];
        require(currentProduct.numberOfStock > 0, "Not enough products in stock to fulfill this order");
        require(currentProduct.owner != msg.sender, "You can't your products");
        currentProduct.numberOfStock--;
        currentProduct.sales++;
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            currentProduct.owner,
            currentProduct.amount
          ),
          "Transfer failed."
        );
        emit ProductOrdered(msg.sender, _index);
    }

    function editQuantity(uint _index, uint edit) public  isOwner(_index){
         Product storage currentProduct = products[_index];  
        require(currentProduct.owner == msg.sender, "You are not the owner")
        require(currentProduct.numberOfStock == 0, "There are still products")
        require(edit > 0, "Input cannot be 0")
     
      currentProduct.numberOfStock += edit; 
    }

    function deleteQuantity(uint _index) public isOwner(_index){
        delete products[_index];
    }
    
    /// @dev get product length
    function getProductLength() public view returns (uint) {
        return (productsLength);
    }
}
