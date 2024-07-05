import MetricsTable, { MetricsTableProps } from './MetricsTable';
import { useMessages } from 'components/hooks';

export function IpTable(props: MetricsTableProps) {
  const { formatMessage, labels } = useMessages();

  return (
    <MetricsTable
      {...props}
      title={formatMessage(labels.ip)}
      type="ip"
      metric={formatMessage(labels.visitors)}
    />
  );
}

export default IpTable;
