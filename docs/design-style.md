# CyCitizenship — Design Style Guide

## Brand Identity

### App Name
- **CyCitizenship** (working title)
- Consider also: CyPrep, CyExam, PassCyprus

### Tagline
- "Your path to Cyprus citizenship"

## Color System

### Primary Palette (Cyprus-inspired)
```
Primary:        #1B5E9E  (Mediterranean blue — trust, reliability)
Primary Light:  #4A8BC7
Primary Dark:   #0D3F6E
Secondary:      #F5A623  (Warm gold — Cyprus sun, achievement)
Secondary Light:#F7BE5C
Secondary Dark: #D4891A
```

### Semantic Colors
```
Success:        #2ECC71  (Correct answers, passed)
Warning:        #F39C12  (LTR pass threshold, streak warning)
Error:          #E74C3C  (Wrong answers, failed)
Info:           #3498DB  (Tips, information)
```

### Neutrals
```
Background:     #F8F9FA  (Light mode)
Surface:        #FFFFFF
Text Primary:   #1A1A2E
Text Secondary: #6C757D
Border:         #E0E0E0
Disabled:       #BDC3C7

Dark Background: #1A1A2E  (Dark mode)
Dark Surface:    #2D2D44
Dark Text:       #F8F9FA
```

### Category Colors (for heatmap/charts)
```
Geography:      #3498DB  (Blue)
Politics:       #9B59B6  (Purple)
Culture:        #E67E22  (Orange)
Daily Life:     #2ECC71  (Green)
```

## Typography

### Font Family
- **Primary**: `Inter` — clean, highly readable, excellent multi-script support
- **Fallback**: System default (Roboto Android, SF Pro iOS)
- **Greek text**: Inter supports Greek glyphs
- **Russian text**: Inter supports Cyrillic

### Type Scale
```
Display Large:  28sp / Bold    — Score display, hero numbers
Display Medium: 24sp / Bold    — Screen titles
Title Large:    22sp / SemiBold — Section headers
Title Medium:   18sp / SemiBold — Card titles
Body Large:     16sp / Regular  — Question text, chat messages
Body Medium:    14sp / Regular  — General content
Body Small:     12sp / Regular  — Captions, metadata
Label:          12sp / Medium   — Buttons, badges
```

### Line Height
- Body text: 1.5x
- Headings: 1.2x
- Compact (buttons/labels): 1.1x

## Spacing System

Base unit: 4dp

```
xs:   4dp    — Icon padding, tight gaps
sm:   8dp    — Between related elements
md:   16dp   — Standard padding, card internal
lg:   24dp   — Section spacing
xl:   32dp   — Screen padding horizontal
xxl:  48dp   — Major section breaks
```

## Component Patterns

### Cards
- Border radius: 12dp
- Elevation: 2dp (light mode), 0dp with border (dark mode)
- Padding: 16dp
- Background: Surface color

### Buttons
- **Primary**: Filled, primary color, white text, 12dp radius, 48dp height
- **Secondary**: Outlined, primary color border, primary text
- **Text**: No background, primary color text
- **Disabled**: 50% opacity

### Answer Options (Exam)
- Default: Outlined card, neutral border
- Selected: Primary color border + light primary fill
- Correct (after submit): Success green border + light green fill + checkmark
- Wrong (after submit): Error red border + light red fill + X mark

### Input Fields
- Border radius: 8dp
- Height: 48dp
- Border: 1dp neutral, 2dp primary on focus
- Error state: red border + error message below

### Bottom Navigation
- 5 items, icon + label
- Active: Primary color
- Inactive: Text secondary
- Height: 64dp

### Chips/Tags
- Border radius: 16dp (pill shape)
- Category chips use category colors
- Difficulty chips: Easy (green), Medium (orange), Hard (red)

## Iconography
- Use Material Icons or Lucide icons
- Icon size: 24dp standard, 20dp compact, 32dp feature
- Consistent stroke weight

## Animations

### Micro-interactions
- Button press: Scale down 95%, 100ms
- Answer selection: Border color transition, 200ms
- Correct answer: Subtle bounce + confetti (on mock exam completion)
- Wrong answer: Gentle shake, 300ms

### Transitions
- Screen transitions: Shared axis (Material Motion)
- Card reveal (flashcard): 3D flip, 400ms
- Score counter: Animated count-up, 1000ms
- Progress bar: Smooth fill, 500ms

### Loading
- Skeleton screens (shimmer effect) for content loading
- Circular progress for AI responses
- Pull-to-refresh with custom animation

## Dark Mode
- Fully supported
- Follows system setting by default, manual override in settings
- Dark surfaces: #1A1A2E base, #2D2D44 cards
- Maintain contrast ratios (WCAG AA)
- Category colors slightly desaturated in dark mode

## Accessibility

### Minimum Requirements (WCAG 2.1 AA)
- Contrast ratio: 4.5:1 for body text, 3:1 for large text
- Touch targets: Minimum 48x48dp
- Focus indicators visible in keyboard/screen reader navigation
- All images have alt text
- Semantic labels on all interactive elements

### Screen Reader Support
- Meaningful content descriptions for questions and options
- Announce score changes, timer updates
- Navigate exam by question (swipe between questions)

### Text Scaling
- Support system text size up to 200%
- Layouts must not break at large text sizes
- Test with largest system font setting

## Responsive Layout
- Designed for phones (360dp - 428dp width)
- Tablet: Two-column layout where appropriate (e.g., question + stats side by side)
- Landscape: Supported but portrait preferred
- Safe area insets respected (notch, home indicator)
