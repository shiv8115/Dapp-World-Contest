// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketBooking {
    address[20] private seatOwners;
    bool[20] private isSeatBooked;
    mapping(address => uint256) countOfTickets;

    //To book seats
    function bookSeats(uint256[] memory seatNumbers) public {
        require(
            seatNumbers.length > 0 && seatNumbers.length <= 4,
            "Invalid number of seats"
        );
        for (uint256 i = 0; i < seatNumbers.length; i++) {
            require(countOfTickets[msg.sender] < 4, "only 4 tickets are allowed");
            uint256 seatNumber = seatNumbers[i];
            require(seatNumber >= 1 && seatNumber <= 20, "Invalid seat number");
            require(!isSeatBooked[seatNumber - 1], "Seat is already booked");
            // Only book the seat if it's available
            isSeatBooked[seatNumber - 1] = true;
            seatOwners[seatNumber - 1] = msg.sender;
            countOfTickets[msg.sender]++;
        }
    }

    //To get available seats
    function showAvailableSeats() public view returns (uint256[] memory) {
        uint256[] memory availableSeats = new uint256[](20);
        uint256 count = 0;
        for (uint256 i = 0; i < 20; i++) {
            if (!isSeatBooked[i]) {
                availableSeats[count] = i + 1;
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = availableSeats[j];
        }
        return result;
    }

    //To check availability of a seat
    function checkAvailability(uint256 seatNumber) public view returns (bool) {
        require(seatNumber >= 1 && seatNumber <= 20, "Invalid seat number");
        return !isSeatBooked[seatNumber - 1];
    }

    //To check tickets booked by the user
    function myTickets() public view returns (uint256[] memory) {
        uint256[] memory bookedSeats = new uint256[](4);
        uint256 count = 0;
        for (uint256 i = 0; i < 20; i++) {
            if (seatOwners[i] == msg.sender) {
                bookedSeats[count] = i + 1;
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = bookedSeats[j];
        }
        return result;
    }
}
