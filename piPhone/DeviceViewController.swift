import UIKit
import RealityKit

final class DeviceViewController: UIViewController {

    private let arView = ARView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var modelEntity: ModelEntity?
    private var modelAnchor = AnchorEntity(world: .zero)

    // Gesture state
    private var currentYaw: Float = 0
    private var currentPitch: Float = 0
    private var currentScale: Float = 1

    // Header sizing
    private let headerHeightRatio: CGFloat = 0.38

    // Simple “Settings-like” rows
    private enum Row: Int, CaseIterable {
        case wifi
        case bluetooth
        case battery
        case storage
        case about

        var title: String {
            switch self {
            case .battery: return "Battery"
            case .wifi: return "Wi-Fi"
            case .bluetooth: return "Bluetooth"
            case .storage: return "Storage"
            case .about: return "About"
            }
        }

        var iconName: String {
            switch self {
            case .battery: return "battery.25"
            case .wifi: return "wifi"
            case .bluetooth: return "bluetooth.materialdesign"
            case .storage: return "externaldrive"
            case .about: return "info.circle"
            }
        }

        /// Only make bluetooth heavier
        var iconWeight: UIImage.SymbolWeight? {
            switch self {
            case .bluetooth: return .bold
            default: return nil
            }
        }

        /// Trailing value (same line). Use nil for none.
        var trailingValue: String? {
            switch self {
            case .battery: return "25%"
            case .wifi: return "Off"
            case .bluetooth: return "On"
            case .storage: return ""
            case .about: return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Gentris's piPhone"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupARViewAsTableHeader()

        loadModel(named: "piPhone-20260104-final") // no ".usdz"
        setupGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderSizeIfNeeded()
    }

    // MARK: - Layout

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = 48

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupARViewAsTableHeader() {
        // Transparent background
        arView.isOpaque = false
        arView.backgroundColor = .clear
        arView.environment.background = .color(.clear)

        // Non-AR viewer mode
        arView.session.pause()
        
        arView.environment.lighting.intensityExponent = 0.5

        // Put ARView inside a container (recommended for tableHeaderView)
        let header = UIView()
        header.backgroundColor = .clear
        header.addSubview(arView)

        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: header.topAnchor),
            arView.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: header.trailingAnchor),
        ])

        // Give an initial size (will be corrected in viewDidLayoutSubviews)
        let initialHeight = view.bounds.height * headerHeightRatio
        header.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: initialHeight)

        tableView.tableHeaderView = header
    }

    private func updateTableHeaderSizeIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }

        let desiredHeight = view.bounds.height * headerHeightRatio
        let desiredWidth = tableView.bounds.width

        // Only update if needed (prevents jumpy scrolling)
        if header.frame.height != desiredHeight || header.frame.width != desiredWidth {
            header.frame = CGRect(x: 0, y: 0, width: desiredWidth, height: desiredHeight)
            tableView.tableHeaderView = header // IMPORTANT: re-assign to apply new height
        }
    }

    // MARK: - Model

    private func loadModel(named name: String) {
        do {
            let entity = try ModelEntity.loadModel(named: name)
            entity.generateCollisionShapes(recursive: true)

            // Center pivot so rotation feels natural
            centerEntityPivot(entity)

            // Scale to real-world size (max dimension ~ 7cm = 0.07m)
            let desiredMaxMeters: Float = 0.07
            let bounds = entity.visualBounds(relativeTo: nil)
            let extents = bounds.extents
            let maxDim = max(extents.x, max(extents.y, extents.z))

            let s: Float = (maxDim > 0) ? (desiredMaxMeters / maxDim) : 1.0
            entity.scale = SIMD3<Float>(repeating: s)
            currentScale = s

            entity.position = SIMD3<Float>(0, 0, -100)

            modelAnchor = AnchorEntity(world: .zero)
            modelAnchor.addChild(entity)

            let light = DirectionalLight()
            light.light.intensity = 10
            light.look(at: SIMD3<Float>(-5000, -5000, -5000), from: SIMD3<Float>(2, 2, 2), relativeTo: nil)
            modelAnchor.addChild(light)

            arView.scene.addAnchor(modelAnchor)
            modelEntity = entity

            applyRotation()

        } catch {
            print("Failed to load model \(name).usdz:", error)
        }
    }

    private func centerEntityPivot(_ entity: ModelEntity) {
        let bounds = entity.visualBounds(relativeTo: nil)
        entity.position -= bounds.center
    }

    // MARK: - Gestures

    private func setupGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinch)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        arView.addGestureRecognizer(pan)
    }

    @objc private func handlePinch(_ gr: UIPinchGestureRecognizer) {
        guard let entity = modelEntity else { return }

        let delta = Float(gr.scale)
        let newScale = max(0.001, min(100.0, currentScale * delta))
        entity.scale = SIMD3<Float>(repeating: newScale)

        if gr.state == .ended || gr.state == .cancelled {
            currentScale = newScale
            gr.scale = 1.0
        }
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        guard modelEntity != nil else { return }

        let translation = gr.translation(in: arView)
        let radiansPerPoint: Float = 0.005

        currentYaw += Float(translation.x) * radiansPerPoint
        currentPitch += Float(-translation.y) * radiansPerPoint

        let maxPitch: Float = .pi / 2.2
        currentPitch = max(-maxPitch, min(maxPitch, currentPitch))

        applyRotation()
        gr.setTranslation(.zero, in: arView)
    }

    private func applyRotation() {
        guard let entity = modelEntity else { return }

        let yawQ = simd_quatf(angle: currentYaw, axis: SIMD3<Float>(0, 1, 0))
        let pitchQ = simd_quatf(angle: currentPitch, axis: SIMD3<Float>(1, 0, 0))
        entity.transform.rotation = yawQ * pitchQ
    }
}

// MARK: - UITableViewDataSource / Delegate

extension DeviceViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = "valueCell"

        // Create a .value1 cell so we get a built-in trailing label (like Settings)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseID)

        guard let row = Row(rawValue: indexPath.row) else { return cell }

        // Reset
        cell.imageView?.image = nil
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator

        // Title + trailing value
        cell.textLabel?.text = row.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.text = row.trailingValue
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .secondaryLabel

        // Left icon
        let base = UIImage(systemName: row.iconName) ?? UIImage(named: row.iconName)

        let icon: UIImage?
        if let weight = row.iconWeight {
            let config = UIImage.SymbolConfiguration(pointSize: 17, weight: weight)
            icon = base?.applyingSymbolConfiguration(config)
        } else {
            icon = base
        }

        cell.imageView?.image = icon
        cell.imageView?.tintColor = .systemBlue

        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }

        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = row.title
        navigationController?.pushViewController(vc, animated: true)
    }
}
