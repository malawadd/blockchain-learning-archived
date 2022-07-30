// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@tableland/evm/contracts/ITablelandTables.sol";

contract Canvas is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Our will be pulled from the network
    string private _baseURIString =
        "https://testnet.tableland.network/query?s=";

    constructor() ERC721("Cavas", "CVS") {}

    /*
     * @dev safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically inserted into the metadata table.
     */

    function safeMint(address to) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();

        /* Any table updates will go here */

        _safeMint(to, newItemId, "");
        _tokenIds.increment();
        return newItemId;
    }

    /*
     * @dev makeMove is an example of how to encode gameplay into both the
     * smart contract and the metadata. Whenever a token owner calls
     * make move, they can supply a new x,y coordinate and update
     * their token metadata.
     */

    function makeMove(
        uint256 tokenId,
        uint256 x,
        uint256 y
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(tokenId < _tokenIds.current());

        require(x < 512 && 0 <= x, "Out of bounds");
        require(y < 512 && 0 <= y, "Out of bounds");

        /* Any table updates will go here */
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    /*
     * @dev tokenURI is an example of how to turn a row in your table back into
     * erc721 compliant metadata JSON. Here, we do a simple SELECT statement
     * with function that converts the result into json.
     */

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        string memory base = _baseURI();

        /* We will give token viewers a way to get at our table metadata */
        return;
    }
}
