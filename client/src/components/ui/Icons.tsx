import { useMemo } from 'react'
import { Icon, Popup, PopupContent, PopupHeader, SemanticICONS } from 'semantic-ui-react'
import { IconProps, IconSizeProp } from 'semantic-ui-react/dist/commonjs/elements/Icon/Icon'

export type { IconSizeProp, SemanticICONS }

// Semantic UI Icons
// https://react.semantic-ui.com/elements/icon/
// https://react.semantic-ui.com/elements/icon/#variations-size

//---------------------------------
// Popup Tooltip
// wrap content in <span> so it will apeear on disabled buttons
//
interface TooltipProps {
  content: string | typeof PopupContent
  header: typeof PopupHeader
  disabledTooltip?: boolean
  cursor?: string
  children: any
}
export function Tooltip({
  header,
  content = 'gabba bagga hey',
  disabledTooltip = false,
  cursor,
  children = null,
}: TooltipProps) {
  const _trigger = disabledTooltip ?
    <span>{children}</span>
    : children
  const _content = Array.isArray(content)
    ? content.map((v, i) => <span key={`e${i}`}>{v}<br /></span>)
    : content
  const _style = cursor ? { cursor: cursor } : {}
  return (
    <span className='Tooltip' style={_style}>
      <Popup
        size='small'
        header={header}
        content={_content}
        trigger={_trigger}
      />
    </span>
  )
}


//---------------------------------
// Info icon + Tooltip
//
interface IconInfoProps {
  size?: IconSizeProp
  content: string | typeof PopupContent
  header: typeof PopupHeader
}
export function IconInfo({
  size, // normal size
  header,
  content = 'gabba bagga hey',
}: IconInfoProps) {
  return (
    <Tooltip header={header} content={content}>
      <Icon name='info circle' size={size} />
    </Tooltip>
  )
}



//---------------------------------
// Loading/Sync spinner
//
interface LoadingIconProps {
  size?: IconSizeProp
  style?: any
  className?: string
}
export function LoadingIcon({
  size = 'small',
  style = {},
  className = '',
}: LoadingIconProps) {
  return (
    <Icon
      className={`ViewCentered NoPadding ${className}`}
      loading
      name='circle notch'
      size={size}
      style={style}
    />)
}


//---------------------------------
// clickable, animated icon
//
interface IconClickProps extends IconProps {
  onClick: Function
  important?: boolean
}
export function IconClick(props: IconClickProps) {
  const classNames = ['IconClick']
  if (props.important) classNames.push('Important')
  const iconProps = useMemo(() => ({ ...props, important: undefined }), [props])
  return (
    <Icon {...iconProps} className={classNames.join(' ')} onClick={() => props.onClick()} />
  )
}

//---------------------------------
// Copy to clipboard
//
interface CopyIconProps extends IconProps {
  content: string
}
export function CopyIcon(props: CopyIconProps) {
  function _copy() {
    navigator?.clipboard?.writeText(props.content)
  }
  return (
    <IconClick {...props} name='copy' onClick={() => _copy()} />
  )
}



//---------------------------------
// Emoji Icon
//
interface EmojiIconProps {
  emoji: string
  size?: IconSizeProp
  style?: any
  className?: string
  disabled?: boolean
  flipped?: 'horizontally' | 'vertically'
  rotated?: 'clockwise' | 'counterclockwise'
}
export function EmojiIcon({
  emoji,
  size,
  style = {},
  className,
  disabled = false,
  flipped,
  rotated,
}: EmojiIconProps) {
  let classNames = [className, 'icon', size, 'NoMargin']
  if (rotated) classNames.push('dirotatedabled')
  if (disabled) classNames.push('disabled')
  if (flipped) classNames.push('flipped')
  return (
    <i className={classNames.join(' ')} style={style}>
      {emoji}
    </i>
  )
}

//-------------------------
// Generic icons
//
export function IconChecked(props: IconProps) {
  return <Icon color='green' {...props} name='check' />
}
export function IconWarning(props: IconProps) {
  return <Icon color='orange' {...props} name='warning' />
}
