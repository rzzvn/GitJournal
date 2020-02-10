import 'package:flutter/material.dart';
import 'package:gitjournal/core/checklist.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';

class ChecklistEditor extends StatefulWidget implements Editor {
  final Note note;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback noteEditorChooserSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;
  @override
  final NoteCallback discardChangesSelected;

  ChecklistEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
  }) : super(key: key);

  @override
  ChecklistEditorState createState() {
    return ChecklistEditorState(note);
  }
}

class ChecklistEditorState extends State<ChecklistEditor>
    implements EditorState {
  Checklist checklist;
  TextEditingController _titleTextController = TextEditingController();

  ChecklistEditorState(Note note) {
    _titleTextController = TextEditingController(text: note.title);
    checklist = Checklist(note);
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var itemTiles = <Widget>[];
    checklist.items.forEach((ChecklistItem item) {
      itemTiles.add(_buildTile(item));
    });
    itemTiles.add(AddItemButton(
      key: UniqueKey(),
      onPressed: () {},
    ));

    print("Building " + checklist.toString());
    Widget checklistWidget = ReorderableListView(
      children: itemTiles,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          /*
          var item = todos.removeAt(oldIndex);

          if (newIndex > oldIndex) {
            todos.insert(newIndex - 1, item);
          } else {
            todos.insert(newIndex, item);
          }
          */
        });
      },
    );

    var titleEditor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: _NoteTitleEditor(_titleTextController),
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this),
      floatingActionButton: buildFAB(widget, this),
      body: Column(
        children: <Widget>[titleEditor, Expanded(child: checklistWidget)],
      ),
    );
  }

  @override
  Note getNote() {
    var note = checklist.note;
    note.title = _titleTextController.text.trim();
    return note;
  }

  ChecklistItemTile _buildTile(ChecklistItem item) {
    return ChecklistItemTile(
      key: UniqueKey(),
      item: item,
      statusChanged: (val) {
        setState(() {
          item.checked = val;
        });
      },
      itemRemoved: () {
        setState(() {
          // FIXME: The body isn't a good indicator, there could be multiple with the same body!
          // todos.removeWhere((t) => t.body == todo.body);
        });
      },
    );
  }
}

class _NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;

  _NoteTitleEditor(this.textController);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.title;

    return TextField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: style,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final Function statusChanged;
  final Function itemRemoved;

  ChecklistItemTile({
    Key key,
    @required this.item,
    @required this.statusChanged,
    @required this.itemRemoved,
  }) : super(key: key);

  @override
  _ChecklistItemTileState createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  TextEditingController _textController;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.text);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subhead;

    var editor = TextField(
      focusNode: _focusNode,
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: style,
      textCapitalization: TextCapitalization.sentences,
      controller: _textController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
    );

    return ListTile(
      dense: true,
      leading: Row(
        children: <Widget>[
          Container(height: 24.0, width: 24.0, child: Icon(Icons.reorder)),
          Checkbox(
            value: widget.item.checked,
            onChanged: widget.statusChanged,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      title: editor,
      trailing: _focusNode.hasFocus
          ? IconButton(
              icon: Icon(Icons.cancel),
              onPressed: widget.itemRemoved,
            )
          : null,
    );
  }
}

class AddItemButton extends StatelessWidget {
  final Function onPressed;

  AddItemButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subhead;

    return ListTile(
      dense: true,
      leading: Row(
        children: <Widget>[
          Container(height: 24.0, width: 24.0),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          )
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      title: Text("Add Item", style: style),
    );
  }
}

// FIXME: The body needs to be scrollable
// FIXME: Add a new todo button
// FIXME: Fix padding issue with todo items
// FIXME: When removing an item the focus should jump to the next/prev in line