---
## title: Skincare Movie Ticketing Smart Contract on the Celo Blockchain
description: In this tutorial, you'll learn how to create a skincare product on Celo Blockchain
authors:
  - name: Johnson Abu
---

## Table of Contents

- [Skincare Movie Ticketing Smart Contract on the Celo Blockchain](#Skincare-Movie-Ticketing-Smart-Contract-on-the-Celo-Blockchain)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#Introduction)
  - [Objective](#objective)
  - [Prerequisites](#Prerequisites)
  - [SmartContract](#SmartContract)
    - [Smart Contract Explanation?](#Smart-Contract-Explanation?)
  - [Deployment Of the Contract](#Deployment-Of-the-Contract)
  - [Frontend](#Frontend)
    - [App.js](#App.js)
    - [Carousel.jsx](#Carousel.jsx) 
    - [Form.jsx](#Form.jsx) 
    - [productCard.jsx](#productCard.jsx) 
  - [Conclusion](#Conclusion)
  - [Next Steps](#Next-Steps)


## Introduction

In this tutorial, we will be explaining a Solidity smart contract called "SkincareProduct". The contract allows users to add skincare products and order them using a custom token called "cUSD". We'll go through each section of the code, explain its purpose, and provide additional information where necessary
## Prerequisites

To follow along with this tutorial, you should have a basic understanding of [Solidity](https://soliditylang.org/) and smart contracts.

Also a basic understanding of web development, which should comprise of Javascript and React.

You should also have an environment set up to deploy and interact with:

- smart contracts, such as [Remix](https://remix.ethereum.org/)
- [Node.js](https://nodejs.org/en) 
- Node Package Manager [npm](https://docs.npmjs.com/)
- A [Celo wallet ](https://celowallet.app/setup) or Celo-compatible wallet extension installed in your browser (e.g. [MetaMask Wallet](https://metamask.io/download/))

## SmartContract

Let's get started writing out our smart contract in Remix IDE

This is the complete code.

```solidity
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SkincareProduct is Ownable {
    using SafeMath for uint256;

    uint internal productsLength = 0;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

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

    mapping (uint => Product) private products;
    
    event ProductAdded(uint productId);
    event ProductRemoved(uint productId);
    event ProductOrdered(address _from, uint productId);
    event StockUpdated(uint productId, uint newStock);

    modifier productExists(uint _index) {
        require(_index < productsLength, "Product doesn't exist");
        _;
    }

    function addProduct(
        string calldata _brand,
        string calldata _image,
        string calldata _category,
        string calldata _deliveredWithin,
        uint _numberOfStock,
        uint _amount
    ) public onlyOwner {
        require(bytes(_brand).length > 0, "Empty brand");
        // similar checks for other parameters

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
        emit ProductAdded(productsLength);
        productsLength++;
    }

    function removeProduct(uint _index) public onlyOwner productExists(_index) {
        delete products[_index];
        emit ProductRemoved(_index);
    }

    function updateStock(uint _index, uint _newStock) public onlyOwner productExists(_index) {
        products[_index].numberOfStock = _newStock;
        emit StockUpdated(_index, _newStock);
    }

    function getProduct(uint _index) public view productExists(_index) returns (
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
    function orderProduct(uint _index) public payable productExists(_index) {
        Product storage currentProduct = products[_index];
        require(currentProduct.numberOfStock > 0, "Not enough products in stock to fulfill this order");
        require(currentProduct.owner != msg.sender, "You can't buy your own products");

        currentProduct.numberOfStock = currentProduct.numberOfStock.sub(1);
        currentProduct.sales = currentProduct.sales.add(1);

        require(
            IERC20(cUsdTokenAddress).transferFrom(
                msg.sender,
                currentProduct.owner,
                currentProduct.amount
            ),
            "Transfer failed."
        );
        emit ProductOrdered(msg.sender, _index);
    }

    function getProductLength() public view returns (uint) {
        return (productsLength);
    }
}
 
```

## Smart Contract Explanation?

Let's explain how the contract works!

**SPDX License Identifier, Solidity Version and Interface Definition**

The `SPDX-License-Identifier` is a special comment that identifies the type of license under which the smart contract is released. In this case, the contract is licensed under the MIT License.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    // Interface functions
}

```

The `pragma` statement specifies the version of Solidity that the contract is compatible with. In this case, it specifies that the contract requires a version greater than or equal to 0.7.0 but less than 0.9.0.

The `interface` declaration defines the interface for an ERC20 token contract. It specifies the required functions and events that a compliant token contract must implement. This interface will be used later in the code.

**Contract Declaration**

```solidity
contract SkincareProduct {
    // Contract variables and mappings
    // Functions and events
}

```

The `contract` declaration defines the SkincareProduct contract. It encapsulates all the variables, mappings, functions, and events defined within it.


**State Variables**

```solidity
uint internal productsLength = 0;
address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

```

- `productsLength` is an internal unsigned integer variable that keeps track of the number of products added to the contract.

- `cUsdTokenAddress` is an internal address variable that stores the address of the cUSD token contract.

**Struct Definition**

```solidity
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

```

The `Product` struct defines the structure of a skincare product. It contains the following fields:

- `owner` - the address of the product owner (payable).
- `brand` - a string representing the brand of the product.
- `image` - a string representing the image of the product.
- `category` - a string representing the category of the product.
- `deliveredWithin` - a string representing the delivery timeline of the product.
- `numberOfStock` - an unsigned integer representing the available stock of the product.
- `amount` - an unsigned integer representing the price of the product.
- `sales` - an unsigned integer representing the number of sales made for the product.

**Mapping**

We will implement a function to retrieve the details of a movie ticket.

```solidity
mapping (uint => Product) private products;

```

The `products` mapping maps a unique identifier (uint) to a Product struct. It is used to store and retrieve products based on their identifier.

**Event**

```solidity
event ProductOrdered(
    address _from,
    uint productId
);

```

The `productOrdered` event is emitted when a product is ordered. It logs the address of the buyer (`_from`) and the product identifier

**Adding a Product**

```solidity
function addProduct(
    string calldata _brand,
    string calldata _image,
    string calldata _category,
    string calldata _deliveredWithin,
    uint _numberOfStock,
    uint _amount
) public {
    // Input validation and requirements
    // Add the product to the products mapping
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

```

The `addProduct` function allows a user to add a new skincare product to the contract. It takes several input parameters that describe the product details.

The function performs the following steps:

- Validates the input parameters to ensure they are not empty and the values are valid.
- Creates a new instance of the `Product` struct with the provided details.
- Assigns the product to the `products` mapping using the `productsLength` as the identifier.
- Increments the `productsLength` variable to maintain a unique identifier for each product.

**Getting a Product**

```solidity
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
    // Retrieve the product from the products mapping based on the given index
    // Return the product details
}

```

The `getProduct` function retrieves the details of a specific product based on its index in the `products` mapping.

The function performs the following steps:

- Retrieves the product from the `products` mapping using the provided `_index`.
- Returns the product details as a tuple containing the owner's address, brand, image, category, delivery timeline, number of stock, price, and number of sales.


**Ordering a Product**

```solidity
function orderProduct(uint _index) public payable {
    // Retrieve the product from the products mapping based on the given index
    // Perform validations on product availability and ownership
    // Decrement the product stock and increment the sales count
    // Transfer the product price in cUSD from the buyer to the product owner
    // Emit the ProductOrdered event
}

```

The `orderProduct` function allows a user to order a skincare product by providing the product index. The user needs to send the required amount of cUSD as payment for the product.

The function performs the following steps:

- Retrieves the product from the `products` mapping using the provided `_index`.
- Validates that the product has available stock and the buyer is not the owner.
- Decrements the product stock and increments the sales count.
- Transfers the product price in cUSD from the buyer to the product owner using the `transferFrom` function of the cUSD token contract.
- Emits the `ProductOrdered` event to indicate a successful order.

**Getting Product Length**

```solidity
function getProductLength() public view returns (uint) {
    return productsLength;
}

```

The `getProductLength` function returns the total number of products that have been added to the contract.

## Deployment Of the Contract

- To deploy our smart contract successfully, we need the celo extention wallet which can be downloaded from [here](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en)

- Create account

- change network to Alfajores Test Network

- Next, we need to fund our newly created wallet which can done using the celo alfojares faucet [Here](https://celo.org/developers/faucet)

- Next we go to [remix](https://remix.ethereum.org/)

- Now, click on the Plugin manager logo at the bottom left corner and search for celo.

- Install the celo plugin and click on the celo logo which will show in the side tab after the plugin is installed.

- Next connect your celo wallet, select the contract you want to deploy and finally click on deploy to deploy your contract.



## Frontend

## App.js

**Setting up the React App**

First, let's set up our React app. Open your terminal and run the following command:

```bash
npx create-react-app skincare-product-store

```

This command will create a new directory named `skincare-product-store` with the basic structure of a React app.

Next, navigate to the app's directory:

```bash
cd skincare-product-store

```

**Installing Dependencies**

In this step, we'll install the necessary dependencies for our app. Run the following commands in your terminal:

```bash
npm install web3 @celo/contractkit bignumber.js

```

These packages will help us interact with the Celo blockchain and handle BigNumber calculations.

**Creating the Contract ABI Files**

In this tutorial, we'll assume that you already have the compiled contract files (`Skincare.sol` and `IERC.sol`) and their corresponding ABIs. If you don't have the ABI files, you'll need to compile the Solidity contracts and generate the ABIs using the appropriate compiler.

Place the `Skincare.abi.json` and `IERC.abi.json` files in the `src/contracts` directory of your React app.

**Creating the Components**

In the `src` directory, create a new directory named `components`. Inside the `components` directory, create three new files: `ProductCard.js`, `Carousel.js`, and `Form.js`.

- ProductCard.js

```javascript
import React from "react";

const ProductCard = ({
  id,
  brand,
  image,
  category,
  deliveredWithin,
  numberOfStock,
  amount,
  orderProduct,
}) => {
  return (
    <div className="product-card">
      <img src={image} alt={brand} />
      <h3>{brand}</h3>
      <p>Category: {category}</p>
      <p>Delivery: {deliveredWithin}</p>
      <p>Stock: {numberOfStock}</p>
      <p>Amount: {amount}</p>
      <button onClick={() => orderProduct(id)}>Order</button>
    </div>
  );
};

export default ProductCard;

```

The `ProductCard` component represents a card displaying information about a skincare product. It receives the product details as props and renders them along with an "Order" button. When the button is clicked, it calls the `orderProduct` function.

- Carousel.js

```javascript
import React from "react";

const Carousel = () => {
  return (
    <div className="carousel">
      {/* Carousel implementation */}
    </div>
  );
};

export default Carousel;

```

The `Carousel` component represents a slideshow of skincare product images. We'll implement the carousel functionality later.

- Form.js

```javascript
import React, { useState } from "react";

const Form = ({ addProduct }) => {
  const [brand, setBrand] = useState("");
  const [image, setImage] = useState("");
  const [category, setCategory] = useState("");
  const [deliveredWithin, setDeliveredWithin] = useState("");
  const [numberOfStock, setNumberOfStock] = useState("");
  const [amount, setAmount] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    addProduct(brand, image, category, deliveredWithin, numberOfStock, amount);
    // Reset form fields
    setBrand("");
    setImage("");
    setCategory("");
    setDeliveredWithin("");
    setNumberOfStock("");
    setAmount("");
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="form-group">
        <label htmlFor="brand">Brand:</label>
        <input
          type="text"
          id="brand"
          value={brand}
          onChange={(e) => setBrand(e.target.value)}
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="image">Image URL:</label>
        <input
          type="text"
          id="image"
          value={image}
          onChange={(e) => setImage(e.target.value)}
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="category">Category:</label>
        <input
          type="text"
          id="category"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="deliveredWithin">Delivered Within:</label>
        <input
          type="text"
          id="deliveredWithin"
          value={deliveredWithin}
          onChange={(e) => setDeliveredWithin(e.target.value)}
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="numberOfStock">Number of Stock:</label>
        <input
          type="number"
          id="numberOfStock"
          value={numberOfStock}
          onChange={(e) => setNumberOfStock(e.target.value)}
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="amount">Amount:</label>
        <input
          type="number"
          id="amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
        />
      </div>
      <button type="submit">Add Product</button>
    </form>
  );
};

export default Form;

```

The `Form` component displays a form for adding a new skincare product. It contains input fields for the brand, image URL, category, delivery time, stock quantity, and price. When the form is submitted, it calls the `addProduct` function and resets the form fields.

**Writing the App Component**

In the `src` directory, open the `App.js` file and replace its contents with the following code:

```javascript
import React, { useState, useEffect, useCallback } from "react";
import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";
import SKINCARE from "./contracts/Skincare.abi.json";
import IERC from "./contracts/IERC.abi.json";
import ProductCard from "./components/ProductCard";
import Carousel from "./components/Carousel";
import Form from "./components/Form";

const ERC20_DECIMALS = 18;
const contractAddress = "0xC628cAd55cD31650014259C7B811A6B2483a8De6";
const cUSDContractAddress = "0x874069fa1eb16d44d622f2e0ca25eea172369bc1"

```

## Carousel.jsx

**Importing React**

```javascript
import React from "react";

```
This line imports the React library, which is necessary for creating React components.

**Define the Carousel Component**

```javascript
function Carousel() {
  return (
    // JSX code representing the Carousel component
  );
}

```

The code defines a functional component called `Carousel`. Functional components are a way to define reusable UI components in React. The `Carousel` component returns JSX code that represents the structure and content of the component.

**Define theJSX Structure of the Carousel Component**

```javascript
<div className="container containercom">
  {/* ... */}
</div>

```

The Carousel component consists of a `<div>` element with the classes "container" and "containercom". This `<div>` acts as the main container for the carousel.

**Create the Carousel Header**

```javascript
<div className="row">
  <div className="col-6">
    <h3 className="mb-3 text-secondary">Just For You</h3>
  </div>
  <div className="col-6 text-right">
    {/* ... */}
  </div>
</div>

```

Inside the main container, there is a `<div>` element with the class "row". It contains two columns created using Bootstrap's grid system (`col-6 class`). In the first column, there is an `<h3>` element with the text "Just For You" and some additional classes for styling.

**Create Carousel Navigation Buttons**

```javascript
<div className="col-6 text-right">
  <a
    className="btn btn-secondary mb-3 mr-1"
    href="#carouselExampleIndicators2"
    role="button"
    data-slide="prev"
  >
    <i className="fa fa-arrow-left"></i>
  </a>
  <a
    className="btn btn-secondary mb-3"
    href="#carouselExampleIndicators2"
    role="button"
    data-slide="next"
  >
    <i className="fa fa-arrow-right"></i>
  </a>
</div>

```

In the second column of the header, there are two navigation buttons created as `<a>` elements. They have Bootstrap classes for styling (`btn, btn-secondary`) and Font Awesome icons (`fa fa-arrow-left` and `fa fa-arrow-right`). These buttons are used to navigate to the previous and next carousel items.

**Create the carousel Content**

```javascript
<div className="col-12">
  <div id="carouselExampleIndicators2" className="carousel slide" data-ride="carousel">
    <div className="carousel-inner">
      {/* Carousel items */}
    </div>
  </div>
</div>

```

Inside the main container, there is another `<div>` element with the class "col-12". It contains the carousel structure defined by the Bootstrap carousel component. The carousel items will be added inside the `<div>` with the class "carousel-inner".

**Create Carousel Items**

```javascript
<div className="carousel-item active">
  <div className="row">
    {/* ... */}
  </div>
</div>
<div className="carousel-item">
  <div className="row">
    {/* ... */}
  </div>
</div>
<div className="carousel-item">
  <div className="row">
    {/* ... */}
  </div>
</div>

```

Inside the carousel's inner container, there are multiple carousel items defined as `<div>` elements with the class "carousel-item". Each carousel item contains a `<div>` with the class "row".

**Create Cards within Carousel Items**

```javascript
<div className="col-md-4 mb-3">
  <div className="card card-size">
    <img className="img-fluid card-img" alt="100%x280" />
    <div className="card-body">
      <h4 className="card-title">Nivea Cream</h4>
      <p className="card-text">Gentle Care for Skin</p>
      <a href="#order_product" className="btn btn-primary">
        Order Product
      </a>
    </div>
  </div>
</div>

```

Within each carousel item, there is a `<div>` element with the class "col-md-4 mb-3". This creates a column within the row that displays a card. The card is defined using the `<div>` with the class "card card-size".

Inside the card, there is an `<img>` element with the class "img-fluid card-img" that represents the image of the product. The `alt` attribute is empty in this code snippet and should be filled with the appropriate image source for each product.

The card's body contains a `<h4>` element with the class "card-title" for the product name, a `<p>` element with the class "card-text" for the product description, and an `<a>` element with the classes "btn btn-primary" for the "Order Product" button.

**Repeat the Steps for Other Products**

The same structure as in Step 8 is repeated for other products within different carousel items. Each product card has a unique image, name, description, and "Order Product" button.

**Complete the Component**

```javascript
return (
  <div className="container containercom">
    <div className="row">
      <div className="col-6">
        <h3 className="mb-3 text-secondary">Just For You</h3>
      </div>
      <div className="col-6 text-right">
        {/* Navigation Buttons */}
      </div>
      <div className="col-12">
        <div id="carouselExampleIndicators2" className="carousel slide" data-ride="carousel">
          <div className="carousel-inner">
            {/* Carousel items */}
          </div>
        </div>
      </div>
    </div>
  </div>
);

```

Finally, the complete JSX structure of the `Carousel` component is returned. It includes the main container, header, navigation buttons, and the carousel structure with its inner container and items.

**Export the Carousel Component**

```javascript
export default Carousel;

```

The `Carousel` component is exported as the default export, making it available for use in other files.

## Form.jsx

**Import React and useState**

```javascript
import React, { useState } from "react";

```

The `React` object is imported from the "react" package, and the `useState` hook is imported from the "react" package as well. This hook allows us to add state to functional components.

**Define the Form component**

```javascript
export default function Form({ addProduct }) {
  // Component code goes here
}

```

The `Form` component is defined as a default export. It takes a prop called `addProduct` which is a function that will be called when the form is submitted.

**Define state and handle Change function**

```javascript
const [editProfileFormData, setEditProfileFormDate] = useState({
  brand: "",
  image: "",
  category: "",
  deliveredWithin: "",
  numberOfStock: "",
  amount: "",
});

const handleChange = (e) => {
  const { name, value } = e.target;
  setEditProfileFormDate({ ...editProfileFormData, [name]: value });
};

```

The `useState` hook is used to define the `editProfileFormData` state object. It contains properties for the brand, image, category, deliveredWithin, numberOfStock, and amount of the product, all initially set to an empty string.

The `handleChange` function is defined to update the state values whenever the user types into the input fields. It uses object destructuring to extract the `name` and `value` from the event target (input field) and then calls `setEditProfileFormDate` to update the corresponding property in the state object.

**Define hand Submit function**

```javascript
function handSubmit(e) {
  e.preventDefault();

  addProduct(
    editProfileFormData.brand,
    editProfileFormData.image,
    editProfileFormData.category,
    editProfileFormData.deliveredWithin,
    editProfileFormData.numberOfStock,
    editProfileFormData.amount
  );
}

```

The `handSubmit` function is called when the form is submitted. It prevents the default form submission behavior to avoid page refresh.

The `addProduct` function (passed as a prop) is called with the values from the `editProfileFormData` state object as arguments. This allows the parent component to handle the submission and process the product data.

**Render the Form component**

```javascript
return (
  <div className="form" onSubmit={(e) => handSubmit(e)}>
    {/* Form JSX goes here */}
  </div>
);

```

The component returns JSX representing the form. It wraps the form content in a `<div>` with the class "form" and sets the `onSubmit` event to call the `handSubmit` function.

**Render the form content**

The JSX code within the `return` statement represents the form content. It includes a container `<div>`, a `<form>` element, and various form fields for the product information.

Each input field is associated with a corresponding property in the `editProfileFormData` state object. The `value` attribute is set to the corresponding state value, and the `onChange` event is set to call the `handleChange` function.

The last `<div>` contains a submit button that triggers the form submission.

That's the breakdown of the provided code. The `Form` component can be used within a React application to render a form for adding a product, and the entered data can be captured and processed using the `addProduct` prop function.

**Assign unique IDs to input fields**

```javascript
<label htmlFor="inputName" className="col-4 col-form-label">
  Name
</label>
<div className="col-8">
  <input
    type="text"
    className="form-control"
    value={editProfileFormData.brand}
    name="brand"
    onChange={(e) => handleChange(e)}
    id="inputName"
    placeholder=" Name"
  />
</div>

```

Each input field in the form has a unique `id` attribute associated with the `label` element. This is done to improve accessibility. The `htmlFor` attribute of the `label` element references the corresponding `id` of the input field.

**Implement form submission**

```javascript
<form>
  {/* Form fields */}
  <div className="mb-3 row">
    <div className="offset-sm-4 col-sm-8">
      <button
        type="submit"
        className="btn btn-primary long-btn btn-secondary"
      >
        ADD PRODUCT
      </button>
    </div>
  </div>
</form>

```

The form is wrapped within a `<form>` element. Inside the form, there are several `<div>` elements containing the form fields.

The last `<div>` contains the submit button, which triggers the form submission when clicked. The button has a type of "submit" and a class of "btn btn-primary long-btn btn-secondary" for styling purposes.

**Handle form submission**

```javascript
<div className="form" onSubmit={(e) => handSubmit(e)}>
  {/* Form content */}
</div>

```

The `onSubmit` event is attached to the outermost `<div>` wrapping the form content. The `handSubmit` function is passed as the event handler and will be called when the form is submitted.

**Export the Form component**

```javascript
export default function Form({ addProduct }) {
  // Component code
}

```

Finally, the `Form` component is exported as the default export of the module, allowing it to be imported and used in other parts of the application.

To use this component in your application, you would import it and pass the `addProduct` function as a prop. The `addProduct` function should handle the logic for adding the product to your data store or performing any other necessary actions.

That's the breakdown of the provided code. It demonstrates a basic form component in React that captures user input for a product and allows the data to be submitted.

**Define the `handleChange` function**

```javascript
const handleChange = (e) => {
  const { name, value } = e.target;
  setEditProfileFormDate({ ...editProfileFormData, [name]: value });
};

```

The `handleChange` function is called whenever the value of an input field changes. It takes an event object `e` as an argument and extracts the `name` and `value` properties from the target input element.

Using destructuring assignment, the `name` and `value` are extracted from `e.target`. The `name` corresponds to the `name` attribute of the input field, and the `value` is the new value entered by the user.

The `setEditProfileFormDate` function is then called with the spread syntax (`...editProfileFormData`) to create a copy of the current `editProfileFormData` state object. The `[name]: value` syntax is used to update the specific field identified by `name` with the new `value`.

**Define the `handSubmit` function**

```javascript
function handSubmit(e) {
  e.preventDefault();

  addProduct(
    editProfileFormData.brand,
    editProfileFormData.image,
    editProfileFormData.category,
    editProfileFormData.deliveredWithin,
    editProfileFormData.numberOfStock,
    editProfileFormData.amount
  );
}

```

The `handSubmit` function is called when the form is submitted. It takes an event object `e` as an argument.

The first line `e.preventDefault()` prevents the default form submission behavior, which would cause a page refresh.

The `addProduct` function, passed as a prop to the `Form` component, is then called with the values from the `editProfileFormData` state object as arguments. These values represent the input fields' values entered by the user.

**Render the form**

```javascript
return (
  <div className="form" onSubmit={(e) => handSubmit(e)}>
    <div className="container conti">
      <form>
        {/* Form fields */}
        {/* Submit button */}
      </form>
    </div>
  </div>
);

```

In the `return` statement, the form is rendered inside a containing `<div>` with the class name "form". The `onSubmit` event is attached to this `<div>`, and it calls the `handSubmit` function when the form is submitted.

The form itself is wrapped in a `<form>` element, and the form fields and submit button are rendered inside it.

**Export the `Form` component**

```javascript
export default function Form({ addProduct }) {
  // Component code
}

```

Finally, the `Form` component is exported as the default export of the module, allowing it to be imported and used in other parts of the application.

To use this `Form` component in your application, you would import it and include it in your parent component, passing the `addProduct` function as a prop. The `addProduct` function should handle the logic for adding the product to your data store or performing any other necessary actions.

## productCard.jsx

**Import React**

```javascript
import React from "react";

```

We start by importing the `React` module, which is required to define and use React components.

**Define the ProductCard component**

```javascript
export default function ProductCard({
  orderProduct,
  id,
  brand,
  image,
  category,
  deliveredWithin,
  numberOfStock,
  amount,
}) {
  // Component code
}

```

The `ProductCard` component is defined as a functional component using the `function` syntax. It takes an object as its argument, which contains the props passed to the component. These props represent the data for a specific product.

**Render the product card**

```javascript
return (
  <div className="card m-3" style={{ width: " 350px" }} key={id}>
    {/* Product image */}
    {/* Product details */}
    {/* Order button */}
  </div>
);

```

The `return` statement defines the JSX code to be rendered by the component. In this case, a `<div>` element with the class name "card" is created. It has some styling applied to set its width to 350 pixels. The `key` attribute is set to the `id` prop value to help React efficiently update and re-render the component when needed.

**Render the product image**

```javascript
<div className="image-div">
  <img src={image} className="card-img-top" alt="..." />
</div>

```

Inside the `<div>` element, an `<img>` element is rendered with the `src` attribute set to the value of the `image` prop. The `className` is set to "card-img-top" to apply appropriate styling, and the `alt` attribute is set to "..." to provide alternative text for the image.

**Render the product details**

```javascript
<div className="card-body">
  <h5 className="card-title d-flex">
    {/* Product brand and category */}
    {/* Product price */}
  </h5>
  <ul className="nav flex-column">
    {/* Delivery time */}
    {/* Stock count */}
  </ul>
</div>

```

Within the `<div>` element with the class name "card-body", the product details are rendered. The product brand and category are displayed inside an `<h5>` element with the class name "card-title". The `d-flex` class is added to make the content flexible and align it properly.

The product price is rendered inside a `<div>` element with the class name "price". The `ms-auto` class is added to push it to the right edge of the card.

The delivery time and stock count are rendered as list items (`<li>`) within a `<ul>` element with the class name "nav flex-column". Each detail is wrapped in a `<b>` element for bold styling.

**Render the order button**

```javascript
<button className="btn btn-primary" onClick={() => orderProduct(id)}>
  Order
</button>

```

A `<button>` element is rendered with the class name "btn btn-primary". When clicked, it triggers the `onClick` event and calls the `orderProduct` function passed as a prop, passing the `id` prop value as an argument.

**Export the ProductCard component**

```javascript
export default ProductCard;

```

The `ProductCard` component is exported as the default export of the module so that it can be imported and used in other parts of the application.

That's it! You have now created a reusable `ProductCard` component that can render product information in a card format. This component can be used in a larger application to display multiple product cards dynamically.

Here's an example of how you can use the `ProductCard` component in a parent component:

```javascript
import React from "react";
import ProductCard from "./ProductCard";

export default function ProductList({ products, orderProduct }) {
  return (
    <div className="product-list">
      {products.map((product) => (
        <ProductCard
          key={product.id}
          orderProduct={orderProduct}
          {...product}
        />
      ))}
    </div>
  );
}

```

In the example above, the `ProductList` component receives an array of `products` as a prop. It iterates over each product and renders a `ProductCard` component for each one. The `orderProduct` function is passed as a prop to the `ProductCard` component, allowing interaction with the order button.

By encapsulating the product card rendering logic in the `ProductCard` component, you can reuse it throughout your application, ensuring consistency and reducing code duplication.

## Conclusion

In this tutorial, we've explained the code for the SkincareProduct smart contract in detail. The contract allows users to add skincare products, retrieve product details, and order products using a custom token. It demonstrates various concepts such as structs, mappings, events, and interactions with external contracts.

## Next Steps

Here are some relevant links that would aid your learning further.

- [Official Celo Docs](https://docs.celo.org/)
- [Official solidity Docs](https://docs.soliditylang.org/en/v0.8.17/)