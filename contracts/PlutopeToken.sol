// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PlutopeToken is ERC20, Ownable(msg.sender) {
    struct TokenDistrubuteInfo {
        string name;
        uint256 Percentage;
        uint256 TokenValue;
    }

    struct privateSaleBuyerInfo {
        address buyer;
        uint256 usdtToken;
        uint256 buyToken;
        bool active;
    }

    struct publicSaleBuyerInfo {
        address buyer;
        uint256 usdtToken;
        uint256 buyToken;
        bool active;
    }

    IERC20 USDTAddress;
    address recipient;
    uint256 public privateSaletokenSold;
    uint256 public publicSaletokenSold;
    uint256 public tokenSold;

    bool public privateSaleStatus = false;
    bool public PublicSaleStatus = false;

    uint256[3] public privateSalePrices;
    uint256[3] public privateSalePhaseTime;

    uint256 public publicSalePrice = 670;
    uint256 public publicSalePhaseTime;

    mapping(address => bool) public WhiteListed;
    address[] public whiteListedList;
    mapping(uint256 => TokenDistrubuteInfo) public TokenDistributeData;
    mapping(address => privateSaleBuyerInfo) public privateSaleBuyerData;
    address[] public privateTokenBuyerList;
    mapping(address => publicSaleBuyerInfo) public publicSaleBuyerData;
    address[] public publicTokenBuyerList;

    constructor(address _address) ERC20("PLUTOPE", "PTP") {
        _mint(address(this), 225000000 * 10**18);
        USDTAddress = IERC20(_address);
        recipient = msg.sender;
        TokenDistrubuteInfo[9] memory arr = [
            TokenDistrubuteInfo("Pre Seed", 50, 11250000 * 10**18),
            TokenDistrubuteInfo("Seed", 133, 30000000 * 10**18),
            TokenDistrubuteInfo("strategic", 60, 13500000 * 10**18),
            TokenDistrubuteInfo("Public Sale", 50, 11250000 * 10**18),
            TokenDistrubuteInfo("Founders/Team", 120, 27000000 * 10**18),
            TokenDistrubuteInfo("Ecosystem", 200, 45000000 * 10**18),
            TokenDistrubuteInfo("Advisors", 25, 5625000 * 10**18),
            TokenDistrubuteInfo("Treasury", 182, 40875000 * 10**18),
            TokenDistrubuteInfo("PartnerShip/Exchanges", 180, 40500000 * 10**18)
        ];

        privateSalePrices = [270, 330, 330];

        for (uint256 i = 0; i < arr.length; i++) {
            TokenDistributeData[i] = arr[i];
        }
    }

    function ChangePrivateSalePrice(uint256 index, uint256 _newPrice)
        public
        onlyOwner
    {
        privateSalePrices[index] = _newPrice;
    }

    function ChangePrivateSaleTime(uint256 index, uint256 _newTime)
        public
        onlyOwner
    {
        privateSalePrices[index] = _newTime;
    }

    function ChangePrivateSaleStatus() public onlyOwner {
        privateSaleStatus = !privateSaleStatus;
        privateSalePhaseTime = [
            block.timestamp + 100,
            block.timestamp + 200 ,
            block.timestamp + 300
        ];
    }

    function ChangePublicSaleStatus() public onlyOwner {
        PublicSaleStatus = !PublicSaleStatus;
        publicSalePhaseTime = block.timestamp + 1500;
    }

    function buyPrivateSaleToken(uint256 _tokenValue) public {
        uint256 tokenvalue = _tokenValue * 10**18;
        require(_tokenValue > 0, "please given a valid Value");
        require(privateSaleStatus == true, "Private sale is not active");
        uint256 tokenPrice;
        if (block.timestamp <= privateSalePhaseTime[0]) {
            tokenPrice = privateSalePrices[0];
        } else if (
            block.timestamp >= privateSalePhaseTime[0] &&
            block.timestamp <= privateSalePhaseTime[1]
        ) {
            tokenPrice = privateSalePrices[1];
            if (TokenDistributeData[0].TokenValue > tokenSold) {
                uint256 remainingToken = TokenDistributeData[0].TokenValue -
                    tokenSold;
                TokenDistributeData[0].TokenValue -= remainingToken;
                TokenDistributeData[1].TokenValue += remainingToken;
            }
        } else if (
            block.timestamp >= privateSalePhaseTime[1] &&
            block.timestamp <= privateSalePhaseTime[2]
        ) {
            tokenPrice = privateSalePrices[2];
            uint256 totalPhaseToken = TokenDistributeData[0].TokenValue +
                TokenDistributeData[1].TokenValue;
            if (totalPhaseToken > tokenSold) {
                uint256 remainingToken = totalPhaseToken - tokenSold;
                TokenDistributeData[1].TokenValue -= remainingToken;
                TokenDistributeData[2].TokenValue += remainingToken;
            }
        }

        uint256 totalUSDT = (tokenvalue * tokenPrice) / 10000;
        address from = msg.sender;
        require(
            USDTAddress.transferFrom(from, recipient, totalUSDT),
            "Transaction is failed"
        );
        _transfer(address(this), msg.sender, tokenvalue);
        if (!WhiteListed[msg.sender]) {
            whiteListedList.push(msg.sender);
        }
        WhiteListed[msg.sender] = true;
        privateSaletokenSold += tokenvalue;
        tokenSold += tokenvalue;
        if (!privateSaleBuyerData[msg.sender].active) {
            privateTokenBuyerList.push(msg.sender);
        }
        privateSaleBuyerData[msg.sender] = privateSaleBuyerInfo({
            buyer: msg.sender,
            usdtToken: privateSaleBuyerData[msg.sender].usdtToken += totalUSDT,
            buyToken: privateSaleBuyerData[msg.sender].buyToken += tokenvalue,
            active: true
        });
    }

    function buyPublicSaleToken(uint256 _tokenValue) public {
        uint256 tokenvalue = _tokenValue * 10**18;
        require(_tokenValue > 0, "please given a valid Value");
        require(PublicSaleStatus == true, "Private sale is not active");
        require(
            block.timestamp < publicSalePhaseTime,
            "Private sale Time is Over"
        );

        uint256 totalPrivateSaleToken = TokenDistributeData[0].TokenValue +
            TokenDistributeData[1].TokenValue +
            TokenDistributeData[2].TokenValue;

        if (totalPrivateSaleToken > tokenSold) {
            uint256 remainingToken = totalPrivateSaleToken - tokenSold;
            TokenDistributeData[2].TokenValue -= remainingToken;
            TokenDistributeData[3].TokenValue += remainingToken;
        }
        uint256 totalUSDT = (tokenvalue * publicSalePrice) / 10000;
        address from = msg.sender;
        require(
            USDTAddress.transferFrom(from, recipient, totalUSDT),
            "Transaction is failed"
        );
        _transfer(address(this), msg.sender, tokenvalue);
        publicSaletokenSold += tokenvalue;
        tokenSold += tokenvalue;
        if (!publicSaleBuyerData[msg.sender].active) {
            publicTokenBuyerList.push(msg.sender);
        }
        publicSaleBuyerData[msg.sender] = publicSaleBuyerInfo({
            buyer: msg.sender,
            usdtToken: publicSaleBuyerData[msg.sender].usdtToken += totalUSDT,
            buyToken: publicSaleBuyerData[msg.sender].buyToken += tokenvalue,
            active: true
        });
    }
}
