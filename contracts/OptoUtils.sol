// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract OptoUtils {
 
  // Function to update the isCall flag
    function setIsCall(bytes1 flags, bool isCall) pure internal returns (bytes1) {
        if (isCall) {
            return  flags |= bytes1(uint8(1) << 3); // Set the 4th bit (isCall bit)
        } else {
            return  flags &= ~bytes1(uint8(1) << 3); // Clear the 4th bit (isCall bit)
        }
    }

    // Function to update the hasToPay flag
    function setHasToPay(bytes1 flags, bool hasToPay)  pure internal returns (bytes1)  {
        if (hasToPay) {
            return  flags |= bytes1(uint8(1) << 2); // Set the 3rd bit (hasToPay bit)
        } else {
            return  flags &= ~bytes1(uint8(1) << 2); // Clear the 3rd bit (hasToPay bit)
        }
    }

    // Function to update the isActive flag
    function setIsActive(bytes1 flags, bool isActive)  pure internal returns (bytes1) {
        if (isActive) {
            return flags |= bytes1(uint8(1) << 1); // Set the 2nd bit (isActive bit)
        } else {
            return flags &= ~bytes1(uint8(1) << 1); // Clear the 2nd bit (isActive bit)
        }
    }

    // Function to update the isPaused flag
    function setIsPaused(bytes1 flags, bool isPaused)  pure internal returns (bytes1) {
        if (isPaused) {
            return  flags |= bytes1(0x01); // Set the 1st bit (isPaused bit)
        } else {
            return  flags &= ~bytes1(0x01); // Clear the 1st bit (isPaused bit)
        }
    }

           // View function to check if the isCall flag is set
    function isCall(bytes1 flags) internal view returns (bool) {
        return (uint8(flags) & (1 << 3)) != 0;
    }

    // View function to check if the hasToPay flag is set
    function hasToPay(bytes1 flags) internal view returns (bool) {
        return (uint8(flags) & (1 << 2)) != 0;
    }

    // View function to check if the isActive flag is set
    function isActive(bytes1 flags) internal view returns (bool) {
        return (uint8(flags) & (1 << 1)) != 0;
    }

    // View function to check if the isPaused flag is set
    function isPaused(bytes1 flags) internal view returns (bool) {
        return (uint8(flags) & 1) != 0;
    }
}

