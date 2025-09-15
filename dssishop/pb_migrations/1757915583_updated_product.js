/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1108966215")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3843317174",
    "max": 0,
    "min": 0,
    "name": "nameshop",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "url2945623539",
    "name": "imageurl",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "url"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number3402113753",
    "max": null,
    "min": null,
    "name": "price",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1108966215")

  // remove field
  collection.fields.removeById("text1579384326")

  // remove field
  collection.fields.removeById("text3843317174")

  // remove field
  collection.fields.removeById("url2945623539")

  // remove field
  collection.fields.removeById("number3402113753")

  return app.save(collection)
})
