import 'package:flutter/material.dart';
// void handleSearch(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         searchResults = [];
//       } else {
//         searchResults = allUsers
//             .where((user) =>
//                 user['username']!.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

void showSearchBottomSheet(BuildContext context ,TextEditingController searchController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        // handleSearch('');
                        setModalState(() {});
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    // handleSearch(value);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                // Expanded(
                //   child: searchResults.isEmpty && searchController.text.isEmpty
                //       ? const Center(child: Text('Start typing to search'))
                //       : searchResults.isEmpty
                //           ? const Center(child: Text('No users found'))
                //           : ListView.builder(
                //               itemCount: searchResults.length,
                //               itemBuilder: (context, index) {
                //                 return ListTile(
                //                   leading: CircleAvatar(
                //                     backgroundImage: NetworkImage(
                //                         searchResults[index]['image']!),
                //                   ),
                //                   title:
                //                       Text(searchResults[index]['username']!),
                //                   onTap: () => Navigator.pop(context),
                //                 );
                //               },
                //             ),
                // ),
              
              ],
            ),
          );
        },
      ),
    );
  }
