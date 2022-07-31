// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@tableland/evm/contracts/ITablelandTables.sol";

import "@tableland/evm/contracts/ITablelandController.sol";

contract Canvas is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Our will be pulled from the network
    string private _baseURIString =
        "https://testnet.tableland.network/query?s=";
    
    ITablelandTables private _tableland;
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _tablePrefix = "canvas"; 

    constructor(
        address registry,
    ) ERC721("Cavas", "CVS") {
        /* 
      * The Tableland address on your current chain
      */
      _tableland = ITablelandTables(registry);

      /*
      * Stores the unique ID for the newly created table.
      */
      _metadataTableId =  _tableland createTable(
        address(this),
        string concat(
            "CREATE TABLE",
            _tablePrefix,
            Strings.toString(block.chainid),
            "(id int, external_link text, x int, y int);"
        )
      );

      /*
      * Stores the full tablename for the new table. 
      * {prefix}_{chainid}_{tableid}
      */

        _metadataTable = string concat(
            _tablePrefix,
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_metadataTableId)
        );
    }

    /*
     * @dev safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically inserted into the metadata table.
     */

    function safeMint(address to) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _tableland.runSQL(
            address(this),
            _metadataTable,
            string concat(
                "INSERT INTO",
                _metadataTable,
                "(id, external_link, x, y) VALUES (",
                Strings.toString(newItemId),
                ", 'not.implemented.xyz', 0, 0);"
            )
        )

        /* Any table updates will go here */

        _safeMint(to, newItemId, "");
        _tokenIds.increment();
        return newItemId;
    }

    /*
     * @dev create a read method on your smart contract to get the final table
     * name in order to query ii
     */

    function metadataURI() public view returns (string memory) {
        string memory base = _baseURI();
        return string concat(
            base, 
            "SELECT%20*%20FROM%20",
            _metadataTable
        );
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


        require(x < 512 && 0 <= x, "Out of bounds");
        require(y < 512 && 0 <= y, "Out of bounds");

        // update the row in tableland
        _tableland.runSQL(
            address(this),
            _metadataTable,
            string concat(
                "UPDATE",
                _metadataTable,
                "SET x = ",
                Strings.toString(x),
                ", y = ",
                Strings.toString(y),
                "WHERE id = ",
                Strings.toString(tokenId),
                ";"
            )
        );

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

    function getPolicy(address sender) public payable override returns (ITablelandController.Policy memory) {
        
         /*
      * Add any custom ACL check here.
      */
        
        return 
        ITablelandController.Policy(
            allowInsert: true,
            allowUpdate: false,
            allowDelete: false,
            whereClause: Policies.joinClauses(new string[](0)),
            withCheck: Policies.joinClauses(new string[](0)),
            updatableColumns: new string[](0)
        );
    }

    function updateController() onlyOwner {
        _tableland.setController(
           address(this),
           _tableId,
           address(this)
         );
     }
}
