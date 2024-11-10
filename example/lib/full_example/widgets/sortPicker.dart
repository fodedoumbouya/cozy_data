import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SortOrder {
  itemAsc,
  itemDesc,
  nameAsc,
  nameDesc,
}

class SortMenu extends StatefulWidget {
  final SortOrder currentSort;
  final Function(SortOrder) onSortChanged;

  const SortMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<SortMenu> createState() => _SortMenuState();
}

class _SortMenuState extends State<SortMenu> {
  void _showMenu(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Column(
          children: [
            SizedBox(
              width: 200,
              child: CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSortChanged(SortOrder.itemAsc);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item (old-new)',
                          style: TextStyle(color: Colors.black),
                        ),
                        if (widget.currentSort == SortOrder.itemAsc)
                          const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSortChanged(SortOrder.itemDesc);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item (new-old)',
                          style: TextStyle(color: Colors.black),
                        ),
                        if (widget.currentSort == SortOrder.itemDesc)
                          const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSortChanged(SortOrder.nameAsc);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Name (A-Z)',
                          style: TextStyle(color: Colors.black),
                        ),
                        if (widget.currentSort == SortOrder.nameAsc)
                          const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSortChanged(SortOrder.nameDesc);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Name (Z-A)',
                            style: TextStyle(color: Colors.black)),
                        if (widget.currentSort == SortOrder.nameDesc)
                          const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(20),
      onPressed: () => _showMenu(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.arrow_up_arrow_down,
            size: 20,
            color: CupertinoColors.activeBlue,
          ),
          SizedBox(width: 4),
          Text(
            'Sort',
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }
}
