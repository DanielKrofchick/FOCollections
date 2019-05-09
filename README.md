# FOCollections

## Features
- Consistent interface across UITableView and UICollectionView.
- Data source is organized by `Section`s and `Item`s. This abstraction allows easier organization and control.
- Lean controller design. `UITableViewDelegate` and `UITableViewDataSource` methods are propagated to `Item`s and `Section`s. This allows most of the customization code to live in the items themselves instead of scattered across the controller. These delegate methods can be overridden at the controller level to handle them there instead.
- Cell sizes automatically cached.
- Layout cells automatically cached.
- Paging is a first class feature. Each section can be paged separately. Paging cell is added and removed automatically as paging state changes.
- UI updates are performed on an operation queue. This allows collection updates to be performed without multiple occurring at the same time and causing a crash, and also sequence updates and their animations.

## Animated updates
UITableView data model updates with animations are supported through `animateUpdates([sections])`. This does a diff calculation between the old data model and the new sections. It then performs the required deletions, insertions, and moves for items and sections, provided that each section and item has a unique identifier. However, if there are duplicate or missing identifiers the update will crash. An area of improvement would be to check for duplicate or missing identifiers, and then provide a warning and update the table through `reloadData()`.
