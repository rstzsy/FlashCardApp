from pathlib import Path
from datetime import datetime

from openpyxl import Workbook
from openpyxl.styles import (
    Font,
    PatternFill,
    Border,
    Side,
    Alignment
)
from openpyxl.chart import BarChart, Reference
from openpyxl.utils import get_column_letter


class ExcelGenerator:

    # color
    PRIMARY_COLOR = "1B365D"       
    PRIMARY_LIGHT = "F4F7FA"       
    ACCENT_COLOR = "4A90E2"        
    
    SUCCESS_COLOR = "E2F0D9"       
    SUCCESS_TEXT = "385723"
    WARNING_COLOR = "FFF2CC"       
    WARNING_TEXT = "7F6000"
    DANGER_COLOR = "FCE4D6"        
    DANGER_TEXT = "C65911"

    FONT_FAMILY = "Segoe UI"

    # font
    TITLE_FONT = Font(name=FONT_FAMILY, bold=True, size=16, color="FFFFFF")
    SECTION_FONT = Font(name=FONT_FAMILY, bold=True, size=12, color="1B365D")
    HEADER_FONT = Font(name=FONT_FAMILY, bold=True, size=11, color="FFFFFF")
    TEXT_FONT = Font(name=FONT_FAMILY, size=11, color="262626")
    BOLD_FONT = Font(name=FONT_FAMILY, bold=True, size=11, color="1B365D")
    ITALIC_FONT = Font(name=FONT_FAMILY, italic=True, size=10, color="595959")
    
    # border
    THIN_BORDER_GRAY = Side(style="thin", color="D9D9D9")
    MEDIUM_BORDER_NAVY = Side(style="medium", color="1B365D")
    
    BORDER_CELL = Border(
        left=THIN_BORDER_GRAY, right=THIN_BORDER_GRAY,
        top=THIN_BORDER_GRAY, bottom=THIN_BORDER_GRAY
    )
    
    # border format for section header
    BORDER_TOTAL = Border(
        top=THIN_BORDER_GRAY,
        bottom=Side(style="double", color="1B365D")
    )

    def generate(
        self,
        roadmap: dict,
        user_info: dict,
        output_folder: str = "exports"
    ) -> str:

        Path(output_folder).mkdir(
            parents=True,
            exist_ok=True
        )

        filename = f"{user_info['userId']}_roadmap.xlsx"
        file_path = str(Path(output_folder) / filename)

        wb = Workbook()

        # create sheets
        self._create_overview_sheet(wb, roadmap, user_info)
        self._create_assessment_sheet(wb, roadmap)
        self._create_strategy_sheet(wb, roadmap)
        self._create_weekly_plan_sheet(wb, roadmap)
        self._create_tracking_sheet(wb, roadmap)

        wb.save(file_path)
        return file_path

    # overview sheet
    def _create_overview_sheet(self, wb, roadmap, user):
        ws = wb.active
        ws.title = "Overview"
        self._enable_gridlines(ws)

        # Banner of sheet
        ws.merge_cells("B2:G3")
        title = ws["B2"]
        title.value = "  PERSONAL LEARNING ROADMAP"
        title.font = self.TITLE_FONT
        title.alignment = Alignment(horizontal="left", vertical="center")
        
        # gradient fill for banner
        for row in ws["B2:G3"]:
            for cell in row:
                cell.fill = PatternFill("solid", fgColor=self.PRIMARY_COLOR)

        # subtitle and user info
        ws.cell(row=5, column=2, value="LEARNER PROFILE").font = self.SECTION_FONT

        info_data = [
            ("User Name", user.get("name", "-")),
            ("Suggested Level", roadmap["studyStrategy"].get("suggestedLevel", "-")),
            ("Daily Target", f"{roadmap['studyStrategy'].get('dailyWordTarget', 0)} words"),
            ("Study Days / Week", f"{roadmap['studyStrategy'].get('studyDaysPerWeek', 0)} days"),
            ("Estimated Duration", f"{roadmap['studyStrategy'].get('estimatedWeeks', 0)} weeks")
        ]

        row_idx = 6
        for label, val in info_data:
            c1 = ws.cell(row=row_idx, column=2, value=label)
            c2 = ws.cell(row=row_idx, column=3, value=val)
            
            c1.font = self.BOLD_FONT
            c2.font = self.TEXT_FONT
            c1.fill = PatternFill("solid", fgColor=self.PRIMARY_LIGHT)
            
            c1.border = self.BORDER_CELL
            c2.border = self.BORDER_CELL
            c1.alignment = Alignment(horizontal="left", vertical="center")
            c2.alignment = Alignment(horizontal="left", vertical="center")
            ws.row_dimensions[row_idx].height = 22
            row_idx += 1

        # motivation message
        row_idx += 1
        ws.cell(row=row_idx, column=2, value="YOUR MOTIVATION").font = self.SECTION_FONT
        
        row_idx += 1
        ws.merge_cells(start_row=row_idx, start_column=2, end_row=row_idx+3, end_column=7)
        moto_cell = ws.cell(row=row_idx, column=2)
        moto_cell.value = f"“ {roadmap.get('motivationMessage', '')} ”"
        moto_cell.font = Font(name=self.FONT_FAMILY, italic=True, size=11, color="404040")
        moto_cell.alignment = Alignment(wrap_text=True, vertical="center", horizontal="center")
        
        # format card style for motivation message
        card_fill = PatternFill("solid", fgColor="F2F4F7")
        for r in range(row_idx, row_idx+4):
            ws.row_dimensions[r].height = 20
            for c in range(2, 8):
                cell = ws.cell(row=r, column=c)
                cell.fill = card_fill
                # thin border for motivation message card
                cell.border = self.BORDER_CELL

        self._auto_width(ws)

    # assessment sheet
    def _create_assessment_sheet(self, wb, roadmap):
        ws = wb.create_sheet("Assessment")
        self._enable_gridlines(ws)

        assessment = roadmap.get("learnerAssessment", {})
        
        sections = [
            ("STRENGTHS", assessment.get("strengths", []), self.SUCCESS_COLOR, self.SUCCESS_TEXT),
            ("WEAKNESSES", assessment.get("weaknesses", []), self.WARNING_COLOR, self.WARNING_TEXT),
            ("RISK FACTORS", assessment.get("riskFactors", []), self.DANGER_COLOR, self.DANGER_TEXT)
        ]

        row = 2
        for title, items, bg_color, text_color in sections:
            # Header group
            cell = ws.cell(row=row, column=2, value=f"  {title}")
            ws.merge_cells(start_row=row, start_column=2, end_row=row, end_column=6)
            
            cell.font = Font(name=self.FONT_FAMILY, bold=True, color=text_color, size=11)
            cell.fill = PatternFill("solid", fgColor=bg_color)
            cell.alignment = Alignment(vertical="center")
            ws.row_dimensions[row].height = 28  # default height
            
            for col in range(2, 7):
                ws.cell(row=row, column=col).border = self.BORDER_CELL

            row += 1

            # list item
            if not items:
                no_item_cell = ws.cell(row=row, column=2, value="   • No data available")
                no_item_cell.font = self.ITALIC_FONT
                ws.merge_cells(start_row=row, start_column=2, end_row=row, end_column=6)
                ws.row_dimensions[row].height = 22
                
                for col in range(2, 7):
                    ws.cell(row=row, column=col).border = Border(bottom=Side(style="thin", color="F0F0F0"))
                row += 1
            else:
                for item in items:
                    item_text = f"   • {item}"
                    val_cell = ws.cell(row=row, column=2, value=item_text)
                    val_cell.font = self.TEXT_FONT
                    ws.merge_cells(start_row=row, start_column=2, end_row=row, end_column=6)
                    
                    # common style for item cells
                    val_cell.alignment = Alignment(vertical="center", horizontal="left", wrap_text=True)
                    
                    # calculation for row height based on content length
                    lines_count = max(len(item_text) // 65, item_text.count('\n')) + 1
                    
                    # 18x10 for each line
                    ws.row_dimensions[row].height = max(lines_count * 18 + 10, 26)
                    
                    # border for item cells
                    for col in range(2, 7):
                        ws.cell(row=row, column=col).border = Border(bottom=Side(style="thin", color="E8E8E8"))
                    row += 1
            
            row += 1 # empty for separation

        self._auto_width(ws)

    # study strategy sheet
    def _create_strategy_sheet(self, wb, roadmap):
        ws = wb.create_sheet("Strategy")
        self._enable_gridlines(ws)

        strategy = roadmap.get("studyStrategy", {})
        
        ws.cell(row=2, column=2, value="METRIC STRATEGY").font = self.SECTION_FONT
        
        headers = ["Metric Key", "Target Value"]
        self._write_header(ws, headers, start_col=2, start_row=3)

        rows = [
            ("Daily Target Words", strategy.get("dailyWordTarget", 0)),
            ("Study Days / Week", strategy.get("studyDaysPerWeek", 0)),
            ("Daily Study Minutes", strategy.get("dailyStudyMinutes", 0)),
            ("Estimated Total Weeks", strategy.get("estimatedWeeks", 0)),
            ("Suggested Course Level", strategy.get("suggestedLevel", ""))
        ]

        for idx, row_data in enumerate(rows, start=4):
            c1 = ws.cell(row=idx, column=2, value=row_data[0])
            c2 = ws.cell(row=idx, column=3, value=row_data[1])
            
            c1.font = self.TEXT_FONT
            c2.font = self.BOLD_FONT
            
            c1.alignment = Alignment(horizontal="left", vertical="center")
            c2.alignment = Alignment(horizontal="right" if isinstance(row_data[1], (int, float)) else "center", vertical="center")
            ws.row_dimensions[idx].height = 24
            
            if idx % 2 == 0:
                fill = PatternFill("solid", fgColor=self.PRIMARY_LIGHT)
                c1.fill = fill
                c2.fill = fill

            c1.border = self.BORDER_CELL
            c2.border = self.BORDER_CELL

        self._auto_width(ws)

    # weekly plan sheet
    def _create_weekly_plan_sheet(self, wb, roadmap):
        ws = wb.create_sheet("Weekly Plan")
        self._enable_gridlines(ws)

        ws.cell(row=2, column=2, value="CURRICULUM TIMELINE").font = self.SECTION_FONT

        # add header for weekly plan table
        headers = ["Week", "Focus Area", "Goal Description", "Study Advice", "Target Words"]
        self._write_header(ws, headers, start_col=2, start_row=3)

        weekly_plan = roadmap.get("weeklyPlan", [])
        daily_word_target = roadmap.get("studyStrategy", {}).get("dailyWordTarget", 0)
        days_per_week = roadmap.get("studyStrategy", {}).get("studyDaysPerWeek", 5)
        
        # cal target words for each week based on daily target and study days per week
        weekly_word_target = daily_word_target * days_per_week

        row = 4
        for item in weekly_plan:
            c1 = ws.cell(row, 2, item.get("week"))
            c2 = ws.cell(row, 3, item.get("focusArea"))
            c3 = ws.cell(row, 4, item.get("goal"))
            c4 = ws.cell(row, 5, item.get("studyAdvice"))
            c5 = ws.cell(row, 6, weekly_word_target)

            # align text for better readability
            c1.alignment = Alignment(horizontal="center", vertical="center")
            c2.alignment = Alignment(horizontal="left", vertical="center")
            c3.alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)
            c4.alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)
            c5.alignment = Alignment(horizontal="right", vertical="center")

            # dynamic row height based on content length
            goal_text = str(item.get("goal") or '')
            advice_text = str(item.get("studyAdvice") or '')
            
            lines_in_goal = max(len(goal_text) // 30, goal_text.count('\n')) + 1
            lines_in_advice = max(len(advice_text) // 40, advice_text.count('\n')) + 1
            
            max_lines = max(lines_in_goal, lines_in_advice)
            
            # each line 16pt
            ws.row_dimensions[row].height = max(max_lines * 16 + 10, 26)

            row_fill = PatternFill("solid", fgColor=self.PRIMARY_LIGHT) if row % 2 == 0 else None
            for col_idx in range(2, 7):
                cell = ws.cell(row, col_idx)
                cell.font = self.TEXT_FONT
                cell.border = self.BORDER_CELL
                if row_fill:
                    cell.fill = row_fill

            row += 1

        ws.freeze_panes = "D4" # default freeze at Goal Description for easy scrolling
        self._auto_width(ws)
        self._create_chart(ws, row)

    # progress tracking sheet
    def _create_tracking_sheet(self, wb, roadmap):
        ws = wb.create_sheet("Progress Tracking")
        self._enable_gridlines(ws)

        ws.cell(row=2, column=2, value="MILESTONE TRACKING").font = self.SECTION_FONT

        headers = ["Week", "Status", "Accuracy (%)", "Notes & Reflections"]
        self._write_header(ws, headers, start_col=2, start_row=3)

        weekly_plan = roadmap.get("weeklyPlan", [])
        row = 4

        for item in weekly_plan:
            c1 = ws.cell(row, 2, item.get("week"))
            c2 = ws.cell(row, 3, "Unassigned")  # status to be updated by user
            c3 = ws.cell(row, 4, "")               
            c4 = ws.cell(row, 5, "")               

            c1.alignment = Alignment(horizontal="center", vertical="center")
            c2.alignment = Alignment(horizontal="center", vertical="center")
            c3.alignment = Alignment(horizontal="right", vertical="center")
            c4.alignment = Alignment(horizontal="left", vertical="center")
            
            ws.row_dimensions[row].height = 26
            
            # format data %
            c3.number_format = '0.0%'

            row_fill = PatternFill("solid", fgColor=self.PRIMARY_LIGHT) if row % 2 == 0 else None
            for col_idx in range(2, 6):
                cell = ws.cell(row, col_idx)
                cell.font = self.TEXT_FONT
                cell.border = self.BORDER_CELL
                if row_fill:
                    cell.fill = row_fill

            row += 1

        self._auto_width(ws)

    # sync layout helper methods
    def _write_header(self, ws, headers, start_col=1, start_row=1):
        """Tạo thanh Header đồng bộ màu sắc thương hiệu"""
        for idx, text in enumerate(headers):
            cell = ws.cell(row=start_row, column=start_col + idx, value=text)
            cell.font = self.HEADER_FONT
            cell.fill = PatternFill("solid", fgColor=self.PRIMARY_COLOR)
            cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
            cell.border = self.BORDER_CELL
        ws.row_dimensions[start_row].height = 30 

    def _enable_gridlines(self, ws):
        """Bảo toàn hiển thị đường kẻ ô lưới nền của Excel khi đổ màu"""
        ws.views.sheetView[0].showGridLines = True

    def _auto_width(self, ws):
        """
        Tính toán độ rộng cột thông minh:
        - Loại trừ các ô đã merge để tránh làm vỡ/quá rộng cột.
        - Tự động thêm khoảng đệm an toàn.
        - Giới hạn độ rộng tối đa để bảng tính gọn gàng.
        """
        # create set for merged cells to skip when calculating width
        merged_cells_set = set()
        for merged_range in ws.merged_cells.ranges:
            for r in range(merged_range.min_row, merged_range.max_row + 1):
                for c in range(merged_range.min_col, merged_range.max_col + 1):
                    if r == merged_range.min_row and c == merged_range.min_col:
                        continue
                    merged_cells_set.add((r, c))

        for column_cells in ws.columns:
            max_length = 0
            column_index = column_cells[0].column
            
            for cell in column_cells:
                # sskip if cell is part of merged
                if (cell.row, cell.column) in merged_cells_set:
                    continue
                
                if cell.value is not None:
                    # choose the longest line
                    lines = str(cell.value).split('\n')
                    for line in lines:
                        max_length = max(max_length, len(line))

            if max_length > 0:
                # add padding and set max width limit
                adjusted_width = min(max_length + 5, 60)
                ws.column_dimensions[get_column_letter(column_index)].width = adjusted_width
            else:
                # default width for empty columns)
                ws.column_dimensions[get_column_letter(column_index)].width = 4

    def _create_chart(self, ws, last_row):
        """Vẽ biểu đồ hình cột hiện đại mô tả chỉ số phân bổ mục tiêu"""
        if last_row <= 4:
            return

        chart = BarChart()
        chart.type = "col"
        chart.title = "Weekly Target Words Distribution"
        chart.style = 24  # Style palette 
        chart.width = 18
        chart.height = 11
        chart.legend = None 

        # get data from f column
        data = Reference(ws, min_col=6, min_row=3, max_row=last_row - 1)
        # categories from b column
        categories = Reference(ws, min_col=2, min_row=4, max_row=last_row - 1)

        chart.add_data(data, titles_from_data=True)
        chart.set_categories(categories)

        # set chart in h column
        ws.add_chart(chart, "H3")