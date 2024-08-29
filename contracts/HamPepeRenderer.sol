// SPDX-License-Identifier: MIT

// this contract is a modification of the Based LP renderer by Deployer
// the contract requires another contract listing the traits, their mapping and their metadata descriptions
// find the referenced imported contracts on github under "Solmate"
// this contract by based-bren 

pragma solidity ^0.8.13;

import "utils/SSTORE2.sol";
import "utils/LibString.sol";
import "auth/Owned.sol";
import "utils/Base64.sol";
import "contracts/HamPepeTraits.sol";

contract HamPepeRenderer is Owned {
    using LibString for uint256;

    HamPepeTraits traitsMetaData;

    address public traitsImagePointer;
    string description = 
    "1000 based Pepes living on Ham Chain L3";

    error TraitsImageAlreadySet ();

    constructor(HamPepeTraits _traitsMetaData) Owned(msg.sender) {
        traitsMetaData = _traitsMetaData;
    }


// this function takes the sprite sheet and saves it on SSTORE2, which saves the data at an eth address
// the data can then be recalled later by just using the address
// this means that it is only gas intensive once, to upload the svg of the sprite sheet

    function setTraitsImage(string calldata data) external onlyOwner {
        if (traitsImagePointer != address(0)) {
            revert TraitsImageAlreadySet();
        }
        traitsImagePointer = SSTORE2.write(bytes(data));
    }

// this functions reads the data of the sprite sheet from SSTORE2 as a string

    function getTraitsImage() public view returns (string memory) {
        return string(SSTORE2.read(traitsImagePointer));
    }

    function updateDescription(string memory d) public onlyOwner {
        description = d;
    }
// this finction is used in combination with the random number "seed" created in the parent contract
// the seed is created at the moment the mint button is pressed using a hash of the current block number

    function _r(
        uint256 seed,
        uint256 from,
        uint256 to 
        ) private pure returns (uint256) {
            return from + (seed % (to - from + 1));
        }

// svg start takes the typical text description of an svg file header, and abi encode turns this into byte code

    function _svgStart() private view returns (string memory) {
        return 
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" height="640" width="640"><defs><image height="1152" width="192" image-rendering="pixelated" id="s" href="data:image/png;base64,',
                    getTraitsImage(),
                    '" /><clipPath id="c"><rect width="64" height="64" /></clipPath></defs><g clip-path="url(#c)">'
                )
            );
    }

// declare the data of traits and seeds

    struct Traits {
        uint256 skin;
        uint256 pants;
        uint256 shirt;
        uint256 eyes;
        uint256 hat;
        uint256 special;
    }

    struct Seeds {
        uint256 one;
        uint256 two;
        uint256 three;
        uint256 four;
        uint256 five;
        uint256 six;
        uint256 seven;
        uint256 eight;
        uint256 nine;
        uint256 ten;
    }

// this function takes the value of the row and column generated in the function _getPart and positions the 40x40 view box over the sprite sheet   

    function _getUseString(uint256 col, uint256 row)
    private pure returns (string memory)
    {
        return 
            string(
                abi.encodePacked(
                    "<use height='64' width='64' href='#s' x='-",
                    col.toString(),
                    "' y='-",
                    row.toString(),
                    "' />"
                )
            );
    }

// this function encodes the image for a given seed in bytecode 

    function getSvgDataUri(bytes32 seed) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(getSvg(seed)))
                )
            );
    }

    // this finction encodes the svg data for the array of traits looped in the _getsvg function

    function _getSvgDataUri(uint256[7] memory traits)
        private
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(_getSvg(traits)))
                )
            );
    }

// this function encodes the json string    

    function getJsonUri(uint256 tokenId, bytes32 seed)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(getJsonString(tokenId, seed)))
                )
            );
    }


// this function builds the metadata from the token id and the mapped traits
// ham pepes have 6 trait types and a background, so the array is 7

    function getJsonString(uint256 tokenId, bytes32 seed)
        public
        view
        returns (string memory)
    {
        uint256[7] memory traits = getTraits(seed);
        return
            string(
                abi.encodePacked(
                    '{"name": "Ham Pepe #',
                    tokenId.toString(),
                    '", "description": "',
                    description,
                    '",',
                    '"image":"',
                    _getSvgDataUri(traits),
                    '","attributes":[',
                    _getTraitMetadata(traits),
                    "]}"
                )
            );
    }

// this function writes the traits string with the assigned values

    function _getTraitString(string memory key, string memory value)
        private
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    key,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

// this function builds the metadata for the token using the current traits of the token
    
    function _getTraitMetadata(uint256[7] memory traits)
        private
        view
        returns (string memory)
    {
        string[6] memory parts;
        for (uint256 i = 0; i < traits.length; i++) {
            uint256 current = traits[i];
            if (i == 0 && current != 0) {
                parts[i] = _getTraitString(
                    "Skin",
                    traitsMetaData.getSkin(current)
                );
            }
            if (i == 1 && current != 0) {
                parts[i] = _getTraitString(
                    "Pants",
                    traitsMetaData.getPants(current)
                );
            }
            if (i == 2 && current != 0) {
                parts[i] = _getTraitString(
                    "Shirt",
                    traitsMetaData.getShirt(current)
                );
            }
            if (i == 3 && current != 0) {
                parts[i] = _getTraitString(
                    "Eyes",
                    traitsMetaData.getEyes(current)
                );
            }
            if (i == 4 && current != 0) {
                parts[i] = _getTraitString(
                    "Hat",
                    traitsMetaData.getHat(current)
                );
            }
            if (i == 5 && current != 0) {
                parts[i] = _getTraitString(
                    "Special",
                    traitsMetaData.getSpecial(current)
                );
            }
       
        }

        string memory output;

        for (uint256 i = 0; i < parts.length; i++) {
            if (bytes(parts[i]).length > 0) {
                output = string(
                    abi.encodePacked(
                        output,
                        bytes(output).length > 0 ? "," : "",
                        parts[i]
                    )
                );
            }
        }

        return output;
    }

    // this function splits up the seed generated in the mint into ten more seeds to use the the _r function to assign the traits

    function getTraits(bytes32 _seed)
        public
        pure
        returns (uint256[7] memory traits)
    {
        uint256 seed = uint256(_seed);

        Seeds memory seeds = Seeds({
            one: uint256(uint16(seed >> 16)),
            two: uint256(uint16(seed >> 32)),
            three: uint256(uint16(seed >> 48)),
            four: uint256(uint16(seed >> 64)),
            five: uint256(uint16(seed >> 80)),
            six: uint256(uint16(seed >> 96)),
            seven: uint256(uint16(seed >> 112)),
            eight: uint256(uint16(seed >> 128)),
            nine: uint256(uint16(seed >> 144)),
            ten: uint256(uint16(seed >> 160))
        });


// this function creates an array of traits, where the rarirty can be controlled to an extent
// for a given seed, the value of _r is calculated. We can then decide a threshold of _r from 1 to 100 
// and for this threshold either give the value of the range of traits or set no trait.
// here no pants, no hat, and no shirt are rare traits
// 60% of Pepes should have the normal skin

bool hasEyes = _r(seeds.four, 1, 100) <= 75;

        traits = [
            // skin
            _r(seeds.one, 1, 100) <= 40 ? _r(seeds.one, 1, 3) : 0, // I don't know why I made this ratio backwards from the rest LMAO
            // pants
            _r(seeds.two, 1, 100) <= 10 ? 0 : _r(seeds.two, 4, 10),
            // shirt
           _r(seeds.three, 1, 100) <= 15 ? 0 : _r(seeds.three, 11, 22),
            // eyes
            //_r(seeds.four, 1, 100) <= 25 ? 0 : _r(seeds.four, 23, 30),
            hasEyes ? _r(seeds.four, 23, 30) : 0,
            // hat
            //_r(seeds.five, 1, 100) <= 15 ? 0 : _r(seeds.five, 31, 47),
            hasEyes && _r(seeds.five, 1, 100) <= 85
                ? _r(seeds.five, 31, 47)
                : 0,
            //special
            _r(seeds.six, 1, 100) <= 20 ? 0 : _r(seeds.six, 48, 53),
            // colours
            _r(seeds.seven, 0, 5)
        ];
    }

    function getSvg(bytes32 _seed) public view returns (string memory) {
        uint256[7] memory traits = getTraits(_seed);
        return _getSvg(traits);
    }

    function _getPart(uint256 tile) internal pure returns (string memory) {
        uint256 col = (tile % 3) * 64;
        uint256 row = (tile / 3) * 64;
        return _getUseString(col, row);
    }

    function _getSvg(uint256[7] memory traits)
        private
        view
        returns (string memory)
    {

        // this is the part of the code where the original renderer has a trait that can go behind the base image, here that is removed
        // the original text is abi.encodePacked(
        // traits[0] != 0 ? _getPart(traits[0]) : "",
        // _getUseString(0, 0)
        // )

        string memory partString = string(
            abi.encodePacked(
                 "",
                _getUseString(0, 0)
            )
        );

        for (uint256 i = 0; i < 6; i++) {  //changed here from i=1 to i=0 because the skin was not being shown
            uint256 tile = traits[i];
            if (tile == 0) {
                continue;
            }

            partString = string(abi.encodePacked(partString, _getPart(tile)));
        }

        return
            string(
                abi.encodePacked(
                    _svgStart(),
                    "<rect width='64' height='64' fill='",
                    traitsMetaData.colours(traits[6]),
                    "' />",
                    partString,
                    "</g></svg>"
                )
            );
    }
}