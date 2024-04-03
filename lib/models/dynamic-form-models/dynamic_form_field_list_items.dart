class ItemModel {
  // int id;
  // int parentId;
  String name;
  ItemModel(
    // this.id,
    this.name,
    // {
    // this.parentId = 0,
    // }
  );

  ItemModel.fromJson(Map<String, dynamic> json)
      // : id = json['id'],
      //   parentId = json['parentId'],
      : name = json['name'];
}
