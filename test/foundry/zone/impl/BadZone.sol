// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    ZoneParameters,
    Schema
} from "../../../../contracts/lib/ConsiderationStructs.sol";

import { ERC165 } from "../../../../contracts/interfaces/ERC165.sol";

import {
    ZoneInterface
} from "../../../../contracts/interfaces/ZoneInterface.sol";

contract BadZone is ERC165, ZoneInterface {
    function validateOrder(
        ZoneParameters calldata zoneParameters
    ) external pure returns (bytes4 validOrderMagicValue) {
        if (zoneParameters.consideration[0].identifier == 1) {
            return ZoneInterface.validateOrder.selector;
        } else {
            assembly {
                return(0, 0)
            }
        }
    }

    /**
     * @dev Returns the metadata for this zone.
     */
    function getSeaportMetadata()
        external
        pure
        override
        returns (
            string memory name,
            Schema[] memory schemas // map to Seaport Improvement Proposal IDs
        )
    {
        schemas = new Schema[](1);
        schemas[0].id = 3003;
        schemas[0].metadata = new bytes(0);

        return ("BadZone", schemas);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, ZoneInterface) returns (bool) {
        return
            interfaceId == type(ZoneInterface).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
