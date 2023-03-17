// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "seaport-sol/SeaportSol.sol";

struct FuzzParams {
    uint256 seed;
}

struct TestContext {
    /**
     * @dev An array of AdvancedOrders
     */
    AdvancedOrder[] orders;
    /**
     * @dev A Seaport interface, either the reference or optimized version.
     */
    SeaportInterface seaport;
    /**
     * @dev A caller address. If this is nonzero, the FuzzEngine will prank this
     *      address before calling exec.
     */
    address caller;
    /**
     * @dev A struct containing fuzzed params generated by the Foundry fuzzer.
     *      Right now these params include only a uint256 seed, which we could
     *      potentially use to generate other random data.
     */
    FuzzParams fuzzParams;
    /**
     * @dev An array of function selectors for "checks". The FuzzEngine will
     *      call these functions after calling exec to make assertions about
     *      the resulting test state.
     */
    bytes4[] checks;
    /**
     * @dev Additional data we might need to fulfill an order. This is basically the
     *      superset of all the non-order args to SeaportInterface functions, like
     *      conduit key, criteria resolvers, and fulfillments.
     */
    uint256 counter;
    bytes32 fulfillerConduitKey;
    CriteriaResolver[] criteriaResolvers;
    address recipient;
}

/**
 * @notice Builder library for TestContext.
 */
library TestContextLib {
    using AdvancedOrderLib for AdvancedOrder;
    using AdvancedOrderLib for AdvancedOrder[];

    /**
     * @dev Create an empty TestContext.
     *
     * @custom:return emptyContext the empty TestContext
     */
    function empty() internal pure returns (TestContext memory) {
        return
            TestContext({
                orders: new AdvancedOrder[](0),
                seaport: SeaportInterface(address(0)),
                caller: address(0),
                fuzzParams: FuzzParams({ seed: 0 }),
                checks: new bytes4[](0),
                counter: 0,
                fulfillerConduitKey: bytes32(0),
                criteriaResolvers: new CriteriaResolver[](0),
                recipient: address(0)
            });
    }

    /**
     * @dev Create a TestContext from the given partial arguments.
     *
     * @param orders the AdvancedOrder[] to set
     * @param seaport the SeaportInterface to set
     * @param caller the caller address to set
     * @param fuzzParams the fuzzParams struct to set
     * @custom:return _context the TestContext
     */
    function from(
        AdvancedOrder[] memory orders,
        SeaportInterface seaport,
        address caller,
        FuzzParams memory fuzzParams
    ) internal pure returns (TestContext memory) {
        return
            TestContext({
                orders: orders,
                seaport: seaport,
                caller: caller,
                fuzzParams: fuzzParams,
                checks: new bytes4[](0),
                counter: 0,
                fulfillerConduitKey: bytes32(0),
                criteriaResolvers: new CriteriaResolver[](0),
                recipient: address(0)
            });
    }

    /**
     * @dev Sets the orders on a TestContext
     *
     * @param context the TestContext to set the orders of
     * @param orders the AdvancedOrder[] to set
     *
     * @return _context the TestContext with the orders set
     */
    function withOrders(
        TestContext memory context,
        AdvancedOrder[] memory orders
    ) internal pure returns (TestContext memory) {
        context.orders = orders.copy();
        return context;
    }

    /**
     * @dev Sets the SeaportInterface on a TestContext
     *
     * @param context the TestContext to set the SeaportInterface of
     * @param seaport the SeaportInterface to set
     *
     * @return _context the TestContext with the SeaportInterface set
     */
    function withSeaport(
        TestContext memory context,
        SeaportInterface seaport
    ) internal pure returns (TestContext memory) {
        context.seaport = seaport;
        return context;
    }

    /**
     * @dev Sets the caller on a TestContext
     *
     * @param context the TestContext to set the caller of
     * @param caller the caller address to set
     *
     * @return _context the TestContext with the caller set
     */
    function withCaller(
        TestContext memory context,
        address caller
    ) internal pure returns (TestContext memory) {
        context.caller = caller;
        return context;
    }

    /**
     * @dev Sets the fuzzParams on a TestContext
     *
     * @param context the TestContext to set the fuzzParams of
     * @param fuzzParams the fuzzParams struct to set
     *
     * @return _context the TestContext with the fuzzParams set
     */
    function withFuzzParams(
        TestContext memory context,
        FuzzParams memory fuzzParams
    ) internal pure returns (TestContext memory) {
        context.fuzzParams = _copyFuzzParams(fuzzParams);
        return context;
    }

    /**
     * @dev Sets the checks on a TestContext
     *
     * @param context the TestContext to set the checks of
     * @param checks the checks array to set
     *
     * @return _context the TestContext with the checks set
     */
    function withChecks(
        TestContext memory context,
        bytes4[] memory checks
    ) internal pure returns (TestContext memory) {
        context.checks = _copyBytes4(checks);
        return context;
    }

    /**
     * @dev Sets the counter on a TestContext
     *
     * @param context the TestContext to set the counter of
     * @param counter the counter value to set
     *
     * @return _context the TestContext with the counter set
     */
    function withCounter(
        TestContext memory context,
        uint256 counter
    ) internal pure returns (TestContext memory) {
        context.counter = counter;
        return context;
    }

    /**
     * @dev Sets the fulfillerConduitKey on a TestContext
     *
     * @param context the TestContext to set the fulfillerConduitKey of
     * @param fulfillerConduitKey the fulfillerConduitKey value to set
     *
     * @return _context the TestContext with the fulfillerConduitKey set
     */
    function withFulfillerConduitKey(
        TestContext memory context,
        bytes32 fulfillerConduitKey
    ) internal pure returns (TestContext memory) {
        context.fulfillerConduitKey = fulfillerConduitKey;
        return context;
    }

    /**
     * @dev Sets the criteriaResolvers on a TestContext
     *
     * @param context the TestContext to set the criteriaResolvers of
     * @param criteriaResolvers the criteriaResolvers array to set
     *
     * @return _context the TestContext with the criteriaResolvers set
     */
    function withCriteriaResolvers(
        TestContext memory context,
        CriteriaResolver[] memory criteriaResolvers
    ) internal pure returns (TestContext memory) {
        context.criteriaResolvers = _copyCriteriaResolvers(criteriaResolvers);
        return context;
    }

    /**
     * @dev Sets the recipient on a TestContext
     *
     * @param context the TestContext to set the recipient of
     * @param recipient the recipient value to set
     *
     * @return _context the TestContext with the recipient set
     */
    function withRecipient(
        TestContext memory context,
        address recipient
    ) internal pure returns (TestContext memory) {
        context.recipient = recipient;
        return context;
    }

    function _copyBytes4(
        bytes4[] memory selectors
    ) private pure returns (bytes4[] memory) {
        bytes4[] memory copy = new bytes4[](selectors.length);
        for (uint256 i = 0; i < selectors.length; i++) {
            copy[i] = selectors[i];
        }
        return copy;
    }

    function _copyCriteriaResolvers(
        CriteriaResolver[] memory criteriaResolvers
    ) private pure returns (CriteriaResolver[] memory) {
        CriteriaResolver[] memory copy = new CriteriaResolver[](
            criteriaResolvers.length
        );
        for (uint256 i = 0; i < criteriaResolvers.length; i++) {
            copy[i] = criteriaResolvers[i];
        }
        return copy;
    }

    function _copyFuzzParams(
        FuzzParams memory params
    ) private pure returns (FuzzParams memory) {
        return FuzzParams({ seed: params.seed });
    }
}
