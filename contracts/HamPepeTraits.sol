// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HamPepeTraits {

    // create a struct that can map the given mapping value to a string name, the name of the trait

    struct TraitInfo {
        mapping(uint256 => string) map;
    }

    TraitInfo skin;
    TraitInfo pants;
    TraitInfo shirt;
    TraitInfo eyes;
    TraitInfo hat;
    TraitInfo special;

    // create an array of background colours in hex value

    string [6] public colours =[
        // Ham Red
        "#ea4949",
        // Mint Green
        "#4fffbe",
        // Apex Blue
        "#00bcfe",
        // Bright Yellow
        "#edd900",
        // Pastel Pink
        "#ffaceb",
        // Flat Grey
        "#a5a5a5"
    ];

// create functions that give the back map for a given seed

    function getSkin(uint256 i) public view returns (string memory) {
        return skin.map[i];
    }

    function getPants(uint256 i) public view returns (string memory) {
        return pants.map[i];
    }

    function getShirt(uint256 i) public view returns (string memory) {
        return shirt.map[i];
    }

    function getEyes(uint256 i) public view returns (string memory) {
        return eyes.map[i];
    }

    function getHat(uint256 i) public view returns (string memory) {
        return hat.map[i];
    }

    function getSpecial(uint256 i) public view returns (string memory) {
        return special.map[i];
    }

    constructor() {
        skin.map[1] = "Skeleton";
        skin.map[2] = "Robot";
        skin.map[3] = "Jelly";

        pants.map[4] = "Orange shorts";
        pants.map[5] = "Pink shorts";
        pants.map[6] = "Grey shorts";
        pants.map[7] = "Brown shorts";

        shirt.map[8] = "Blue shirt";
        shirt.map[9] = "Miami DAO";
        shirt.map[10] = "Baseball";
        shirt.map[11] = "Overalls";
        shirt.map[12] = "Unicorn floaty";
        shirt.map[13] = "Black tracksuit";
        shirt.map[14] = "Red tracksuit";
        shirt.map[15] = "Raincoat";
        shirt.map[16] = "Fast food";

        eyes.map[17] = "Shades";
        eyes.map[18] = "Sunnyside";
        eyes.map[19] = "Noggles";
        eyes.map[20] = "3D Glasses";
        eyes.map[21] = "Smoked";
        eyes.map[22] = "Mask";
        eyes.map[23] = "Cool";
        eyes.map[24] = "Viper";

        hat.map[25] = "Classic";
        hat.map[26] = "Degen";
        hat.map[27] = "Wizard";
        hat.map[28] = "Based";
        hat.map[29] = "Fez";
        hat.map[30] = "Headphones";
        hat.map[31] = "Halo";
        hat.map[32] = "Cowboy";
        hat.map[33] = "Spinner";
        hat.map[34] = "Band";
        hat.map[35] = "Beanie";
        hat.map[36] = "Sprout";
        hat.map[37] = "Crown";
        hat.map[38] = "Pirate";
        hat.map[39] = "Party";
        hat.map[40] = "Leprechaun";
        hat.map[41] = "Rooster";

        special.map[42] = "Cigarette";
        special.map[43] = "Vape";
        special.map[44] = "Pipe";
        special.map[45] = "Puke";
        special.map[46] = "Bubble";
        special.map[47] = "Cigar";
    }
    }

    