# FOCollections

Features:
- Consistent interface across UITableView and UICollectionView.
- Data source is organized by Sections and Items. This abstraction allows better organization and control.
- Lean controller design. UITableViewDelegate and UITableViewDataSource methods are propogated to Items and Sections. This allows most of the customization code to live in the items themselves instead of scattered across the controller. Of cource these delegate methods can always be overridden at the controller level to handle them there instead.
- Cell sizes automatically cached.
- Layout cells automatically cached.
- Paging is a first class feature. Each section can be paged seperately. Paging cell is added and removed automatically as paging state changes.
- UI updates are performed on an operation queue. This allows us to perform collection updates without worrying about multiple accuring at the same time and causing a crash. We can also sequence updates and their animations easily.
