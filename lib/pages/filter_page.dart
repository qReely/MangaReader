import 'package:flutter/material.dart';

import '../search_filter.dart';

class FilterPage extends StatefulWidget {
  final List<String> genres;
  final List<String> statuses;
  const FilterPage({Key? key, required this.genres, required this.statuses}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<FilterPage> {
  final List<String> _selectedGenres = [];
  final List<String> _selectedStatuses = [];
  List<int> _selectedChapters = [0,1000];
  List<double> _selectedRating = [0.0, 10.0];


  void _genreChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedGenres.add(itemValue);
      } else {
        _selectedGenres.remove(itemValue);
      }
    });
  }

  void _statusChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedStatuses.add(itemValue);
      } else {
        _selectedStatuses.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, [SearchFilter(genres: _selectedGenres, statuses: _selectedStatuses, chapters: _selectedChapters, rating: _selectedRating)]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Filter Search'),
      content: SizedBox(
        height: 600,
        width: 600,
        child: Column(
          children: [
            const Text("Genres"),
            SizedBox(
              height: 60,
              width: 400,
              child: ListView.builder(
                itemCount: widget.genres.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String genre = widget.genres[index];
                  return IntrinsicWidth(
                    child: ListTile(
                      leading: _selectedGenres.contains(genre) ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                      title: Text(genre, style: const TextStyle(fontSize: 14),),
                      onTap: () {
                        _genreChange(genre, !_selectedGenres.contains(genre));
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40,),
            const Text("Statuses"),
            SizedBox(
              height: 60,
              child: ListView.builder(
                itemCount: widget.statuses.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String status = widget.statuses[index];
                  return IntrinsicWidth(
                    child: ListTile(
                      leading: _selectedStatuses.contains(status) ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                      title: Text(status, style: const TextStyle(fontSize: 14),),
                      onTap: () {
                        _statusChange(status, !_selectedStatuses.contains(status));
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40,),
            const Text("Chapters"),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 80,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "From",
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    maxLength: 4,
                    onChanged: (value) {
                      try {
                        _selectedChapters[0] = int.parse(value);
                      }
                      catch (e) {
                        print(e.toString());
                      }
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "To",
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    maxLength: 4,
                    onChanged: (value) {
                      try {
                        _selectedChapters[1] = int.parse(value);
                      }
                      catch (e) {
                        print(e.toString());
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40,),
            const Text("Rating"),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 80,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "From",
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    maxLength: 4,
                    onChanged: (value) {
                      try {
                        value = value.replaceAll(",", ".");
                        _selectedRating[0] = double.parse(value) < 0 ? 0 : double.parse(value);
                      }
                      catch (e) {
                        print(e.toString());
                      }
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "To",
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    maxLength: 4,
                    onChanged: (value) {
                      try {
                        value = value.replaceAll(",", ".");
                        _selectedRating[1] = double.parse(value) > 10 ? 10 : double.parse(value);
                      }
                      catch (e) {
                        print(e.toString());
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}