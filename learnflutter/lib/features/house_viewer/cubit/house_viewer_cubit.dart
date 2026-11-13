import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'house_viewer_state.dart';

class HouseViewerCubit extends Cubit<HouseViewerState> {
  HouseViewerCubit()
      : super(HouseViewerState(
            house: parts.first.house,
            group: parts.first.group,
            part: parts.first));

  static const _ext = HousePartGroup.exterior;
  static const _room = HousePartGroup.rooms;
  static const _det = HousePartGroup.details;
  static const _mod = HousePartGroup.modules;

  // Plan (X right, Z front): kitchen (-X,-Z) | bath (+X,-Z) / living (-X,+Z) | bedroom (+X,+Z).
  // theta: 0 = seen from the front (+Z), 90 = right, 180 = back, 270 = left.
  static const List<HousePart> parts = [
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: '3/4 view',
        model: HouseModel.detailed,
        theta: 35,
        phi: 65,
        radius: 85,
        description:
            'Whole house with yard: gable roof, chimney, front porch.'),
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: 'Front',
        model: HouseModel.detailed,
        theta: 0,
        phi: 80,
        radius: 70,
        description:
            'Front face (+Z): main door, 2 shuttered windows, canopy, steps.'),
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: 'Right',
        model: HouseModel.detailed,
        theta: 90,
        phi: 80,
        radius: 70,
        description:
            'Right face (+X): bedroom window with shutters, small bathroom window, chimney.'),
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: 'Back',
        model: HouseModel.detailed,
        theta: 180,
        phi: 80,
        radius: 70,
        description:
            'Back face (-Z): back door with stoop, kitchen and bathroom windows, AC unit.'),
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: 'Left',
        model: HouseModel.detailed,
        theta: 270,
        phi: 80,
        radius: 70,
        description:
            'Left face (-X): living-room window with shutters, kitchen window.'),
    HousePart(
        house: HouseType.villa,
        group: _ext,
        label: 'Roof',
        model: HouseModel.detailed,
        theta: 0,
        phi: 10,
        radius: 85,
        description: 'Top view: gable roof, ridge cap, gutters, chimney.'),
    HousePart(
        house: HouseType.villa,
        group: _room,
        label: 'Floor plan',
        model: HouseModel.interior,
        theta: 0,
        phi: 8,
        radius: 80,
        description:
            'Roof removed: kitchen + bathroom at the back, living room + bedroom at the front.'),
    HousePart(
        house: HouseType.villa,
        group: _room,
        label: 'Living room',
        model: HouseModel.interior,
        theta: 20,
        phi: 40,
        radius: 40,
        tx: -2.0,
        ty: 0.8,
        tz: 1.8,
        description:
            'Sofa, coffee table, rug, TV stand, plant and floor lamp.'),
    HousePart(
        house: HouseType.villa,
        group: _room,
        label: 'Kitchen',
        model: HouseModel.interior,
        theta: 15,
        phi: 40,
        radius: 40,
        tx: -2.0,
        ty: 0.8,
        tz: -2.0,
        description:
            'Counter with sink, stove, wall cabinets, fridge, dining table with 4 chairs.'),
    HousePart(
        house: HouseType.villa,
        group: _room,
        label: 'Bedroom',
        model: HouseModel.interior,
        theta: 330,
        phi: 40,
        radius: 40,
        tx: 3.3,
        ty: 0.8,
        tz: 2.0,
        description:
            'Bed with pillows and blanket, 2 nightstands with lamps, wardrobe.'),
    HousePart(
        house: HouseType.villa,
        group: _room,
        label: 'Bathroom',
        model: HouseModel.interior,
        theta: 340,
        phi: 40,
        radius: 40,
        tx: 3.3,
        ty: 0.8,
        tz: -2.0,
        description: 'Bathtub, toilet, vanity with mirror.'),
    HousePart(
        house: HouseType.villa,
        group: _det,
        label: 'Front door',
        model: HouseModel.detailed,
        theta: 15,
        phi: 80,
        radius: 30,
        tx: -1.5,
        ty: 1.5,
        tz: 4.6,
        description:
            'Door with frame and raised panels, knob, house number, canopy posts, stone steps.'),
    HousePart(
        house: HouseType.villa,
        group: _det,
        label: 'Shutters',
        model: HouseModel.detailed,
        theta: 25,
        phi: 80,
        radius: 30,
        tx: -3.8,
        ty: 1.5,
        tz: 4.0,
        description:
            'Front window: frame, muntins, glass, stone ledge, shutters on both sides.'),
    HousePart(
        house: HouseType.villa,
        group: _det,
        label: 'Back door',
        model: HouseModel.detailed,
        theta: 195,
        phi: 75,
        radius: 30,
        tx: -0.4,
        ty: 1.8,
        tz: -4.4,
        description:
            'Wooden back door with stoop and the AC unit mounted on the wall.'),
    HousePart(
        house: HouseType.villa,
        group: _det,
        label: 'Chimney',
        model: HouseModel.detailed,
        theta: 40,
        phi: 60,
        radius: 30,
        tx: 3.5,
        ty: 5.0,
        tz: -1.6,
        description:
            'Brick chimney with stone cap rising through the back roof slope.'),

    // ---- Nhà ống 4 x 22 m: khách+bếp thông nhau (trước), hành lang bên phải,
    // 2 phòng ngủ, WC, sân phơi lộ thiên (cuối nhà). Front = +Z.
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: '3/4 view',
        model: HouseModel.tube,
        theta: 35,
        phi: 65,
        radius: 85,
        description:
            'Nhà bê tông cốt thép 4 x 22 m, sân thượng vườn + mái che, cầu thang xoắn từ sân phơi, hàng rào + cổng.'),
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: 'Front',
        model: HouseModel.tube,
        theta: 0,
        phi: 80,
        radius: 55,
        tz: 6,
        description:
            'Mặt tiền: cửa chính, cửa sổ có chớp, mái hiên, bậc thềm, hàng rào.'),
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: 'Right',
        model: HouseModel.tube,
        theta: 90,
        phi: 80,
        radius: 90,
        description:
            'Hông phải (+X): cửa sổ khách, bếp, 2 ô thoáng hành lang.'),
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: 'Left',
        model: HouseModel.tube,
        theta: 270,
        phi: 80,
        radius: 90,
        description: 'Hông trái (-X): cửa sổ khách, bếp, 2 phòng ngủ, WC.'),
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: 'Back',
        model: HouseModel.tube,
        theta: 180,
        phi: 80,
        radius: 55,
        tz: -6,
        description: 'Mặt sau: tường sân phơi, cửa sổ, dàn lạnh, vòi nước.'),
    HousePart(
        house: HouseType.tube,
        group: _ext,
        label: 'Roof',
        model: HouseModel.tube,
        theta: 90,
        phi: 10,
        radius: 85,
        description:
            'Nhìn từ trên: mái che ở phía trước, luống rau, rồi vườn (cỏ, luống hoa) ở phía sau gần cầu thang; sân phơi không mái.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Floor plan',
        model: HouseModel.tubeInterior,
        theta: 90,
        phi: 8,
        radius: 85,
        description:
            'Bỏ mái: khách+bếp -> (hành lang phải) PN1, PN2, WC -> sân phơi.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Living + kitchen',
        model: HouseModel.tubeInterior,
        theta: 20,
        phi: 45,
        radius: 38,
        tx: 0,
        ty: 0.8,
        tz: 6.5,
        description:
            'Khách: sofa + gối, bàn trà (bình hoa, sách), pouf, TV + soundbar, điều hoà, tranh, rèm, móc áo, thảm chùi chân. Bếp: bếp + máy hút mùi, nồi ấm, nồi cơm, lò vi sóng, giá úp bát, tủ lạnh, bàn ăn 4 ghế (dĩa, ly, giỏ trái cây), đèn thả, đồng hồ.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Bedroom 1',
        model: HouseModel.tubeInterior,
        theta: 300,
        phi: 45,
        radius: 22,
        tx: -0.5,
        ty: 0.8,
        tz: 0.2,
        description:
            'Phòng ngủ 1: giường (gối, chăn, tranh đầu giường), 2 tủ đầu giường + đèn + đồng hồ, tủ quần áo có hộp trên nóc, bàn trang điểm + gương + ghế đẩu, điều hoà, rèm, thảm.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Bedroom 2',
        model: HouseModel.tubeInterior,
        theta: 300,
        phi: 45,
        radius: 22,
        tx: -0.5,
        ty: 0.8,
        tz: -3.2,
        description:
            'Phòng ngủ 2: giường + gấu bông, bàn học (laptop, sách, đèn bàn) + ghế, hộp đồ chơi + bóng, tủ quần áo, khung ảnh, điều hoà, rèm, thảm.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Toilet',
        model: HouseModel.tubeInterior,
        theta: 300,
        phi: 45,
        radius: 20,
        tx: -0.5,
        ty: 0.6,
        tz: -6.2,
        description:
            'WC: ốp gạch quanh tường, bồn cầu (nắp, nút xả, giấy vệ sinh, vòi xịt), lavabo (vòi, ly bàn chải, xà phòng) + gương đèn, thanh khăn, buồng tắm kính (vòi sen, kệ chai, cống), thảm, thùng rác.'),
    HousePart(
        house: HouseType.tube,
        group: _room,
        label: 'Drying yard',
        model: HouseModel.tubeInterior,
        theta: 30,
        phi: 45,
        radius: 28,
        tx: 0,
        ty: 1.2,
        tz: -9.2,
        description:
            'Sân phơi lộ thiên: lát gạch có ron, 2 dây phơi + quần áo, máy giặt, chậu cây, giỏ đồ, cuộn vòi nước, cây lau nhà + chổi, đèn tường, vòi nước, cống thoát.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Front door',
        model: HouseModel.tube,
        theta: 15,
        phi: 80,
        radius: 22,
        tx: 0.8,
        ty: 1.5,
        tz: 12.0,
        description:
            'Cửa chính, bậc thềm đá, mái hiên 2 cột, số nhà, cổng hàng rào.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Side windows',
        model: HouseModel.tube,
        theta: 270,
        phi: 80,
        radius: 25,
        tx: -2.0,
        ty: 1.5,
        tz: 0.5,
        description:
            'Cửa sổ phòng ngủ phía hông trái: khung, ô kính chia, bệ đá, chớp.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Yard wall',
        model: HouseModel.tube,
        theta: 200,
        phi: 70,
        radius: 25,
        tx: 0,
        ty: 1.8,
        tz: -11.0,
        description:
            'Tường sau sân phơi: cửa sổ thoáng, dàn lạnh, vòi nước, gờ tường.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Roof garden',
        model: HouseModel.tube,
        theta: 200,
        phi: 50,
        radius: 30,
        tx: 0,
        ty: 3.4,
        tz: -3.0,
        description:
            'Vườn phía sau sân thượng (cạnh lối lên): bãi cỏ + lối đá, luống hoa hai bên, ghế gỗ, 2 chậu chanh.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Pergola',
        model: HouseModel.tube,
        theta: 30,
        phi: 55,
        radius: 28,
        tx: 0,
        ty: 4.2,
        tz: 8.0,
        description:
            'Mái che khung thép + tấm polycarbonate dốc thoát nước, bàn ăn ngoài trời, đèn dây, bếp nướng, bồn nước inox, luống rau ngay sau mái che.'),
    HousePart(
        house: HouseType.tube,
        group: _det,
        label: 'Spiral stair',
        model: HouseModel.tube,
        theta: 120,
        phi: 70,
        radius: 22,
        tx: -1.0,
        ty: 2.0,
        tz: -8.7,
        description:
            'Cầu thang xoắn bê tông 17 bậc quanh trụ thép, tay vịn thép, từ sân phơi lên chiếu nghỉ ở sân thượng.'),

    // ---- Modules: mỗi phòng / khu vực là một glb riêng (cắt từ nhà ống).
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng khách',
        model: HouseModel.tubeLiving,
        theta: 35,
        phi: 45,
        radius: 75,
        tx: 0,
        ty: 1.6,
        tz: 9.0,
        description:
            'Phòng khách (z 5,4 – 12,6): sofa + gối + chăn, bàn trà, pouf, TV + soundbar, điều hoà, tranh, đèn đứng, kệ giày, móc áo, mặt tiền với cửa chính, cửa sổ + rèm, mái hiên và bậc thềm.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng khách (top)',
        model: HouseModel.tubeLiving,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: 0,
        ty: 1.6,
        tz: 9.0,
        description:
            'Phòng khách (z 5,4 – 12,6): sofa + gối + chăn, bàn trà, pouf, TV + soundbar, điều hoà, tranh, đèn đứng, kệ giày, móc áo, mặt tiền với cửa chính, cửa sổ + rèm, mái hiên và bậc thềm.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Bếp + ăn',
        model: HouseModel.tubeKitchen,
        theta: 35,
        phi: 45,
        radius: 75,
        tx: 0,
        ty: 1.6,
        tz: 3.7,
        description:
            'Bếp + bàn ăn (z 1,9 – 5,5): tủ bếp + bếp từ + máy hút mùi, chậu rửa, tủ lạnh, nồi cơm, lò vi sóng, bàn ăn 4 ghế với placemat, giỏ trái cây, tường ngăn về phía phòng ngủ.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Bếp + ăn (top)',
        model: HouseModel.tubeKitchen,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: 0,
        ty: 1.6,
        tz: 3.7,
        description:
            'Bếp + bàn ăn (z 1,9 – 5,5): tủ bếp + bếp từ + máy hút mùi, chậu rửa, tủ lạnh, nồi cơm, lò vi sóng, bàn ăn 4 ghế với placemat, giỏ trái cây, tường ngăn về phía phòng ngủ.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng ngủ 1',
        model: HouseModel.tubeBed1,
        theta: 60,
        phi: 45,
        radius: 75,
        tx: -0.8,
        ty: 1.6,
        tz: 0.25,
        description:
            'Phòng ngủ chính (z -1,6 – 2,1): giường + gối + chăn, tủ đầu giường, tủ quần áo, bàn trang điểm + gương, tranh, điều hoà, thảm.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng ngủ 1 (top)',
        model: HouseModel.tubeBed1,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: -0.8,
        ty: 1.6,
        tz: 0.25,
        description:
            'Phòng ngủ chính (z -1,6 – 2,1): giường + gối + chăn, tủ đầu giường, tủ quần áo, bàn trang điểm + gương, tranh, điều hoà, thảm.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng ngủ 2',
        model: HouseModel.tubeBed2,
        theta: 60,
        phi: 45,
        radius: 75,
        tx: -0.8,
        ty: 1.6,
        tz: -3.25,
        description:
            'Phòng ngủ 2 (z -5,1 – -1,4): giường, bàn học + laptop + đèn bàn, hộp đồ chơi, gấu bông, khung ảnh, điều hoà.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Phòng ngủ 2 (top)',
        model: HouseModel.tubeBed2,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: -0.8,
        ty: 1.6,
        tz: -3.25,
        description:
            'Phòng ngủ 2 (z -5,1 – -1,4): giường, bàn học + laptop + đèn bàn, hộp đồ chơi, gấu bông, khung ảnh, điều hoà.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'WC',
        model: HouseModel.tubeWc,
        theta: 60,
        phi: 45,
        radius: 75,
        tx: -0.8,
        ty: 1.6,
        tz: -6.25,
        description:
            'Nhà vệ sinh (z -7,6 – -4,9): bồn cầu + vòi xịt, chậu rửa + gương đèn, buồng tắm có vòi sen, ốp gạch 1,2 m, thanh khăn, thùng rác.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'WC (top)',
        model: HouseModel.tubeWc,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: -0.8,
        ty: 1.6,
        tz: -6.25,
        description:
            'Nhà vệ sinh (z -7,6 – -4,9): bồn cầu + vòi xịt, chậu rửa + gương đèn, buồng tắm có vòi sen, ốp gạch 1,2 m, thanh khăn, thùng rác.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Hành lang',
        model: HouseModel.tubeCorridor,
        theta: 300,
        phi: 45,
        radius: 75,
        tx: 1.7,
        ty: 1.6,
        tz: -2.7,
        description:
            'Hành lang 0,9 m bên phải (z -7,6 – 2,1): thảm trải dài, tranh, đèn tường, hộp điện, 3 cửa vào phòng ngủ 1, 2 và WC.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Hành lang (top)',
        model: HouseModel.tubeCorridor,
        theta: 0,
        phi: 8,
        radius: 70,
        tx: 1.7,
        ty: 1.6,
        tz: -2.7,
        description:
            'Hành lang 0,9 m bên phải (z -7,6 – 2,1): thảm trải dài, tranh, đèn tường, hộp điện, 3 cửa vào phòng ngủ 1, 2 và WC.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Sân phơi + thang',
        model: HouseModel.tubeYardStair,
        theta: 200,
        phi: 45,
        radius: 70,
        tx: 0,
        ty: 2.2,
        tz: -9.5,
        description:
            'Sân phơi lộ thiên và cầu thang xoắn bê tông 17 bậc lên sân thượng: dây phơi, máy giặt, chậu cây, vòi nước, tay vịn thép, chiếu nghỉ.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Sân phơi + thang (top)',
        model: HouseModel.tubeYardStair,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: 0,
        ty: 2.2,
        tz: -9.5,
        description:
            'Sân phơi lộ thiên và cầu thang xoắn bê tông 17 bậc lên sân thượng: dây phơi, máy giặt, chậu cây, vòi nước, tay vịn thép, chiếu nghỉ.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Mái che',
        model: HouseModel.tubePergola,
        theta: 30,
        phi: 50,
        radius: 70,
        tx: 0,
        ty: 4.6,
        tz: 8.2,
        description:
            'Mái che sân thượng phía trước: khung thép, tấm polycarbonate, bàn ăn ngoài trời 4 ghế, đèn thả, đèn dây, bếp nướng, bồn nước inox, chậu cây.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Mái che (top)',
        model: HouseModel.tubePergola,
        theta: 0,
        phi: 8,
        radius: 80,
        tx: 0,
        ty: 4.6,
        tz: 8.2,
        description:
            'Mái che sân thượng phía trước: khung thép, tấm polycarbonate, bàn ăn ngoài trời 4 ghế, đèn thả, đèn dây, bếp nướng, bồn nước inox, chậu cây.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Vườn sân thượng',
        model: HouseModel.tubeRoofGarden,
        theta: 200,
        phi: 50,
        radius: 70,
        tx: 0,
        ty: 4.2,
        tz: -1.3,
        description:
            'Vườn phía sau sân thượng: bãi cỏ + lối đá, 2 luống hoa, 2 luống rau có cọc, ghế dài, chậu chanh, lan can bê tông và chiếu nghỉ cầu thang.'),
    HousePart(
        house: HouseType.tube,
        group: _mod,
        label: 'Vườn sân thượng (top)',
        model: HouseModel.tubeRoofGarden,
        theta: 0,
        phi: 8,
        radius: 70,
        tx: 0,
        ty: 4.2,
        tz: -1.3,
        description:
            'Vườn phía sau sân thượng: bãi cỏ + lối đá, 2 luống hoa, 2 luống rau có cọc, ghế dài, chậu chanh, lan can bê tông và chiếu nghỉ cầu thang.'),
  ];

  static List<HousePart> partsOf(HouseType h, HousePartGroup g) =>
      parts.where((p) => p.house == h && p.group == g).toList();

  static HousePart _first(HouseType h) => parts.firstWhere((p) => p.house == h);

  // The viewer disposes its controller's notifier, so every (re)created
  // viewer needs a fresh controller.
  Flutter3DController viewer = Flutter3DController();

  void selectHouse(HouseType house) {
    if (house == state.house) return;
    final part = _first(house);
    selectPart(part, house: house, group: part.group);
  }

  void selectGroup(HousePartGroup group) {
    if (group == state.group) return;
    selectPart(partsOf(state.house, group).first, group: group);
  }

  void selectPart(HousePart part, {HouseType? house, HousePartGroup? group}) {
    final sameModel = part.model == state.part.model;
    if (sameModel) {
      emit(state.copyWith(
          house: house ?? state.house,
          group: group ?? state.group,
          part: part));
      if (state.status == HouseViewerStatus.ready) _applyCamera(part);
      return;
    }
    viewer = Flutter3DController();
    emit(state.copyWith(
      house: house ?? state.house,
      group: group ?? state.group,
      part: part,
      status: HouseViewerStatus.loading,
      progress: 0,
      clearError: true,
      reloadToken: state.reloadToken + 1,
    ));
  }

  void reload() {
    viewer = Flutter3DController();
    emit(state.copyWith(
        status: HouseViewerStatus.loading,
        progress: 0,
        clearError: true,
        reloadToken: state.reloadToken + 1));
  }

  void resetCamera() {
    if (state.status == HouseViewerStatus.ready) _applyCamera(state.part);
  }

  void onProgress(double value) {
    if (state.status != HouseViewerStatus.loading) return;
    emit(state.copyWith(progress: value));
  }

  void onLoaded() {
    emit(state.copyWith(
        status: HouseViewerStatus.ready, progress: 1, clearError: true));
    _applyCamera(state.part);
    if (state.autoRotate) viewer.startRotation();
  }

  void onLoadFailed(String error) {
    emit(state.copyWith(status: HouseViewerStatus.error, errorMessage: error));
  }

  void toggleAutoRotate(bool value) {
    emit(state.copyWith(autoRotate: value));
    if (state.status != HouseViewerStatus.ready) return;
    value ? viewer.startRotation() : viewer.stopRotation();
  }

  void _applyCamera(HousePart p) {
    viewer.setCameraTarget(p.tx, p.ty, p.tz);
    viewer.setCameraOrbit(p.theta, p.phi, p.radius);
  }
}
