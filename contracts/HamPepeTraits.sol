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
        pants.map[8] = "Tan pants";
        pants.map[9] = "Blue jeans";
        pants.map[10] = "Kilt";

        shirt.map[11] = "Blue shirt";
        shirt.map[12] = "Miami DAO";
        shirt.map[13] = "Baseball";
        shirt.map[14] = "Overalls";
        shirt.map[15] = "Unicorn floaty";
        shirt.map[16] = "Black tracksuit";
        shirt.map[17] = "Red tracksuit";
        shirt.map[18] = "Raincoat";
        shirt.map[19] = "Fast food";
        shirt.map[20] = "Intern";
        shirt.map[21] = "Bowling shirt";
        shirt.map[22] = "Baja Hoodie";

        eyes.map[23] = "Shades";
        eyes.map[24] = "Sunnyside";
        eyes.map[25] = "Noggles";
        eyes.map[26] = "3D Glasses";
        eyes.map[27] = "Smoked";
        eyes.map[28] = "Mask";
        eyes.map[29] = "Cool";
        eyes.map[30] = "Viper";

        hat.map[31] = "Classic";
        hat.map[32] = "Degen";
        hat.map[33] = "Wizard";
        hat.map[34] = "Based";
        hat.map[35] = "Fez";
        hat.map[36] = "Headphones";
        hat.map[37] = "Halo";
        hat.map[38] = "Cowboy";
        hat.map[39] = "Spinner";
        hat.map[40] = "Band";
        hat.map[41] = "Beanie";
        hat.map[42] = "Sprout";
        hat.map[43] = "Crown";
        hat.map[44] = "Pirate";
        hat.map[45] = "Party";
        hat.map[46] = "Leprechaun";
        hat.map[47] = "Rooster";

        special.map[48] = "Cigarette";
        special.map[49] = "Vape";
        special.map[50] = "Pipe";
        special.map[51] = "Puke";
        special.map[52] = "Bubble";
        special.map[53] = "Cigar";
    }
    }

    